;; -------------------------------------
;; Override modus vivendi styles
;; -------------------------------------
(defun rc/apply-everforest-style ()
  (interactive)
  (setopt modus-themes-italic-constructs t
          modus-themes-bold-constructs t
          modus-themes-mixed-fonts nil
          modus-themes-prompts '(ultrabold)
          modus-themes-common-palette-overrides
          `((accent-0                      "#7FBBB3")
            (accent-1                      "#83C092")
            (bg-active                     bg-main)
            (bg-added                      "#3C4841")
            (bg-added-refine               "#4A5C53")
            (bg-changed                    "#384B55")
            (bg-changed-refine             "#475E6C")
            (bg-completion                 "#374145")
            (bg-completion-match-0         "#272E33")
            (bg-completion-match-1         "#272E33")
            (bg-completion-match-2         "#272E33")
            (bg-completion-match-3         "#272E33")
            (bg-hl-line                    "#2E383C")
            (bg-hover-secondary            "#495156")
            (bg-line-number-active         unspecified)
            (bg-line-number-inactive       "#272E33")
            (bg-main                       "#272E33")
            (bg-dim                        "#1E2326")
            (bg-mark-delete                "#493B40")
            (bg-mark-select                "#384B55")
            (bg-mode-line-active           "#1E2326")
            (bg-mode-line-inactive         "#1E2326")
            (bg-prominent-err              "#493B40")
            (bg-prompt                     unspecified)
            (bg-prose-block-contents       "#2E383C")
            (bg-prose-block-delimiter      bg-prose-block-contents)
            (bg-region                     "#495156")
            (bg-removed                    "#493B40")
            (bg-removed-refine             "#5C4448")
            (bg-tab-bar                    "#272E33")
            (bg-tab-current                bg-main)
            (bg-tab-other                  "#272E33")
            (border-mode-line-active       nil)
            (border-mode-line-inactive     nil)
            (builtin                       "#7FBBB3")
            (comment                       "#859289")
            (constant                      "#E67E80")
            (cursor                        "#D3C6AA")
            (date-weekday                  "#7FBBB3")
            (date-weekend                  "#E69875")
            (docstring                     "#9DA9A0")
            (err                           "#E67E80")
            (fg-active                     fg-main)
            (fg-completion                 "#D3C6AA")
            (fg-completion-match-0         "#7FBBB3")
            (fg-completion-match-1         "#E67E80")
            (fg-completion-match-2         "#A7C080")
            (fg-completion-match-3         "#E69875")
            (fg-heading-0                  "#E67E80")
            (fg-heading-1                  "#E69875")
            (fg-heading-2                  "#DBBC7F")
            (fg-heading-3                  "#A7C080")
            (fg-heading-4                  "#7FBBB3")
            (fg-line-number-active         "#D3C6AA")
            (fg-line-number-inactive       "#7A8478")
            (fg-link                       "#7FBBB3")
            (fg-main                       "#D3C6AA")
            (fg-mark-delete                "#E67E80")
            (fg-mark-select                "#7FBBB3")
            (fg-mode-line-active           "#D3C6AA")
            (fg-mode-line-inactive         "#495156")
            (fg-prominent-err              "#E67E80")
            (fg-prompt                     "#D699B6")
            (fg-prose-block-delimiter      "#859289")
            (fg-prose-verbatim             "#A7C080")
            (fg-region                     "#D3C6AA")
            (fnname                        "#7FBBB3")
            (fringe                        unspecified)
            (identifier                    "#D699B6")
            (info                          "#83C092")
            (keyword                       "#D699B6")
            (name                          "#7FBBB3")
            (number                        "#E69875")
            (property                      "#7FBBB3")
            (string                        "#A7C080")
            (type                          "#DBBC7F")
            (variable                      "#E69875")
            (warning                       "#DBBC7F")
            (bg-term-black                 "#495156")
            (fg-term-black                 "#495156")
            (bg-term-black-bright          "#495156")
            (fg-term-black-bright          "#495156")
            (bg-term-red                   "#E67E80")
            (fg-term-red                   "#E67E80")
            (bg-term-red-bright            "#E67E80")
            (fg-term-red-bright            "#E67E80")
            (bg-term-green                 "#A7C080")
            (fg-term-green                 "#A7C080")
            (bg-term-green-bright          "#A7C080")
            (fg-term-green-bright          "#A7C080")
            (bg-term-yellow                "#DBBC7F")
            (fg-term-yellow                "#DBBC7F")
            (bg-term-yellow-bright         "#DBBC7F")
            (fg-term-yellow-bright         "#DBBC7F")
            (bg-term-blue                  "#7FBBB3")
            (fg-term-blue                  "#7FBBB3")
            (bg-term-blue-bright           "#7FBBB3")
            (fg-term-blue-bright           "#7FBBB3")
            (bg-term-magenta               "#D699B6")
            (fg-term-magenta               "#D699B6")
            (bg-term-magenta-bright        "#D699B6")
            (fg-term-magenta-bright        "#D699B6")
            (bg-term-cyan                  "#83C092")
            (fg-term-cyan                  "#83C092")
            (bg-term-cyan-bright           "#83C092")
            (fg-term-cyan-bright           "#83C092")
            (bg-term-white                 "#D3C6AA")
            (fg-term-white                 "#D3C6AA")
            (bg-term-white-bright          "#D3C6AA")
            (fg-term-white-bright          "#D3C6AA"))))

;; -------------------------------------
;; Clear background hooks
;; -------------------------------------
(defun rc/clear-background-color (&optional frame)
  (interactive)
  (or frame (setq frame (selected-frame)))
  "unsets the background color in terminal mode"
  (unless (display-graphic-p frame)
    ;; Set the terminal to a transparent version of the background color
    (send-string-to-terminal
     (format "\033]11;[90]%s\033\\"
         (face-attribute 'default :background)))
    (set-face-background 'default "unspecified-bg" frame)))

;; -------------------------------------
;; Window divider
;; -------------------------------------
(setq window-divider-default-right-width 15
      window-divider-default-bottom-width 15
      window-divider-default-places t)

(window-divider-mode 1)

(defun rc/style-window-dividers ()
  "Make window dividers match background."
  (modus-themes-with-colors
    (custom-set-faces
     `(window-divider ((,c :foreground ,bg-main)))
     `(window-divider-first-pixel ((,c :foreground ,bg-main)))
     `(window-divider-last-pixel ((,c :foreground ,bg-main))))))

(add-hook 'modus-themes-after-load-theme-hook #'rc/style-window-dividers)

;; ------------------------------------------
;; Install & load modus-vivendi-tinted theme
;; ------------------------------------------
(rc/require 'modus-themes)
(rc/apply-everforest-style)
(load-theme 'modus-vivendi-tinted t)
(add-hook 'modus-themes-after-load-theme-hook #'rc/clear-background-color)
(rc/style-window-dividers)

(provide 'theme-rc)
