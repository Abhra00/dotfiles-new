// --- CONFIGURATION ---
const vec4 TRAIL_COLOR = vec4(0.898, 0.788, 0.627, 1.0); // #e5c9a0
const float DURATION = 0.2;
const float TRAIL_SIZE = 0.8;
const float THRESHOLD_MIN_DISTANCE = 1.5;
const float BLUR = 1.0;
const float TRAIL_THICKNESS = 1.0;
const float TRAIL_THICKNESS_X = 0.9;
const float FADE_ENABLED = 0.0;
const float FADE_EXPONENT = 5.0;

const float PI = 3.14159265359;
const float C1_BACK = 1.70158;
const float C3_BACK = C1_BACK + 1.0;
const float C4_ELASTIC = (2.0 * PI) / 3.0;

// EaseOutCirc
float ease(float x) {
    return sqrt(1.0 - pow(x - 1.0, 2.0));
}

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b) {
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);
    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    s *= mix(1.0, -1.0, step(0.5, allCond + noneCond));
    return d;
}

float getSdfConvexQuad(in vec2 p, in vec2 v1, in vec2 v2, in vec2 v3, in vec2 v4) {
    float s = 1.0;
    float d = dot(p - v1, p - v1);
    d = seg(p, v1, v2, s, d);
    d = seg(p, v2, v3, s, d);
    d = seg(p, v3, v4, s, d);
    d = seg(p, v4, v1, s, d);
    return s * sqrt(d);
}

float getDurationFromDot(float dot_val, float DURATION_LEAD, float DURATION_SIDE, float DURATION_TRAIL) {
    float isLead = step(0.5, dot_val);
    float isSide = step(-0.5, dot_val) * (1.0 - isLead);
    return mix(mix(DURATION_TRAIL, DURATION_SIDE, isSide), DURATION_LEAD, isLead);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif

    // Normalize to [-1,1] space
    vec2 vu = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;

    vec4 currentCursor  = vec4((iCurrentCursor.xy  * 2.0 - iResolution.xy) / iResolution.y,
                                iCurrentCursor.zw  * 2.0 / iResolution.y);
    vec4 previousCursor = vec4((iPreviousCursor.xy * 2.0 - iResolution.xy) / iResolution.y,
                                iPreviousCursor.zw * 2.0 / iResolution.y);

    vec2 offsetFactor = vec2(-0.5, 0.5);
    vec2 centerCC = currentCursor.xy  - currentCursor.zw  * offsetFactor;
    vec2 centerCP = previousCursor.xy - previousCursor.zw * offsetFactor;

    vec2 moveVec = centerCC - centerCP;
    float lineLengthSq = dot(moveVec, moveVec);
    float minDist = currentCursor.w * THRESHOLD_MIN_DISTANCE;
    float baseProgress = iTime - iTimeCursorChange;

    vec4 newColor = fragColor;

    if (lineLengthSq > minDist * minDist && baseProgress < DURATION - 0.001) {

        // Current cursor corners
        float cc_cx = currentCursor.x + currentCursor.z * 0.5;
        float cc_cy = currentCursor.y - currentCursor.w * 0.5;
        float cc_hw = currentCursor.z * 0.5 * TRAIL_THICKNESS_X;
        float cc_hh = currentCursor.w * 0.5 * TRAIL_THICKNESS;
        vec2 cc_tl = vec2(cc_cx - cc_hw, cc_cy + cc_hh);
        vec2 cc_tr = vec2(cc_cx + cc_hw, cc_cy + cc_hh);
        vec2 cc_bl = vec2(cc_cx - cc_hw, cc_cy - cc_hh);
        vec2 cc_br = vec2(cc_cx + cc_hw, cc_cy - cc_hh);

        // Previous cursor corners
        float cp_cx = previousCursor.x + previousCursor.z * 0.5;
        float cp_cy = previousCursor.y - previousCursor.w * 0.5;
        float cp_hw = previousCursor.z * 0.5 * TRAIL_THICKNESS_X;
        float cp_hh = previousCursor.w * 0.5 * TRAIL_THICKNESS;
        vec2 cp_tl = vec2(cp_cx - cp_hw, cp_cy + cp_hh);
        vec2 cp_tr = vec2(cp_cx + cp_hw, cp_cy + cp_hh);
        vec2 cp_bl = vec2(cp_cx - cp_hw, cp_cy - cp_hh);
        vec2 cp_br = vec2(cp_cx + cp_hw, cp_cy - cp_hh);

        const float DURATION_TRAIL = DURATION;
        const float DURATION_LEAD  = DURATION * (1.0 - TRAIL_SIZE);
        const float DURATION_SIDE  = (DURATION_LEAD + DURATION_TRAIL) * 0.5;

        vec2 s = sign(moveVec);

        float dot_tl = dot(vec2(-1.,  1.), s);
        float dot_tr = dot(vec2( 1.,  1.), s);
        float dot_bl = dot(vec2(-1., -1.), s);
        float dot_br = dot(vec2( 1., -1.), s);

        float isMovingRight = step(0.5,  s.x);
        float isMovingLeft  = step(0.5, -s.x);

        float dur_left_rail  = getDurationFromDot((dot_tl + dot_bl) * 0.5, DURATION_LEAD, DURATION_SIDE, DURATION_TRAIL);
        float dur_right_rail = getDurationFromDot((dot_tr + dot_br) * 0.5, DURATION_LEAD, DURATION_SIDE, DURATION_TRAIL);

        float final_dur_tl = mix(getDurationFromDot(dot_tl, DURATION_LEAD, DURATION_SIDE, DURATION_TRAIL), dur_left_rail,  isMovingLeft);
        float final_dur_bl = mix(getDurationFromDot(dot_bl, DURATION_LEAD, DURATION_SIDE, DURATION_TRAIL), dur_left_rail,  isMovingLeft);
        float final_dur_tr = mix(getDurationFromDot(dot_tr, DURATION_LEAD, DURATION_SIDE, DURATION_TRAIL), dur_right_rail, isMovingRight);
        float final_dur_br = mix(getDurationFromDot(dot_br, DURATION_LEAD, DURATION_SIDE, DURATION_TRAIL), dur_right_rail, isMovingRight);

        vec2 v_tl = mix(cp_tl, cc_tl, ease(clamp(baseProgress / final_dur_tl, 0.0, 1.0)));
        vec2 v_tr = mix(cp_tr, cc_tr, ease(clamp(baseProgress / final_dur_tr, 0.0, 1.0)));
        vec2 v_br = mix(cp_br, cc_br, ease(clamp(baseProgress / final_dur_br, 0.0, 1.0)));
        vec2 v_bl = mix(cp_bl, cc_bl, ease(clamp(baseProgress / final_dur_bl, 0.0, 1.0)));

        float sdfTrail = getSdfConvexQuad(vu, v_tl, v_tr, v_br, v_bl);

        // Antialiasing — skip on H/V movement to avoid pulse artifact
        float isDiagonal = abs(s.x * s.y);
        float effectiveBlur = (BLUR < 2.5) ? mix(0.0, BLUR, isDiagonal) : BLUR;
        float blurNorm = effectiveBlur * 2.0 / iResolution.y;
        float shapeAlpha = 1.0 - smoothstep(0.0, blurNorm, sdfTrail);

        vec4 trail = TRAIL_COLOR;
        if (FADE_ENABLED > 0.5) {
            float fadeProgress = clamp(dot(vu - centerCP, moveVec) / (lineLengthSq + 1e-6), 0.0, 1.0);
            trail.a *= pow(fadeProgress, FADE_EXPONENT);
        }

        float finalAlpha = trail.a * shapeAlpha;
        newColor = mix(newColor, vec4(trail.rgb, newColor.a), finalAlpha);

        // Punch hole so current cursor renders on top
        float sdfCC = getSdfRectangle(vu, centerCC, currentCursor.zw * 0.5);
        newColor = mix(newColor, fragColor, step(sdfCC, 0.0));
    }

    fragColor = newColor;
}
