;; -------------------------------------
;; Override modus vivendi styles
;; -------------------------------------
(defun rc/apply-palenight-style ()
  (interactive)
  (setopt modus-themes-italic-constructs t
          modus-themes-bold-constructs t
          modus-themes-mixed-fonts nil
          modus-themes-prompts '(ultrabold)
          modus-themes-common-palette-overrides
          `((bg-main                   "#292D3E")
            (bg-active                 bg-main)
            (fg-main                   "#EEFFFF")
            (fg-active                 fg-main)
            (fringe                    unspecified)
            (bg-line-number-active     bg-main)
            (bg-line-number-inactive   bg-main)
            (fg-line-number-active     fg-main)
            (fg-line-number-inactive   "#676E95")
            (border-mode-line-active   unspecified)
            (border-mode-line-inactive unspecified)
            (fg-mode-line-active       "#A6Accd")
            (bg-mode-line-active       "#232635")
            (fg-mode-line-inactive     "#676E95")
            (bg-mode-line-inactive     "#282c3d")
            (bg-tab-bar                "#242837")
            (bg-tab-current            bg-main)
            (bg-tab-other              bg-active)
            (fg-prompt                 "#c792ea")
            (bg-prompt                 unspecified)
            (bg-hover-secondary        "#676E95")
            (bg-completion             "#2f447f")
            (fg-completion             "#FFFFFF")
            (bg-region                 "#3C435E")
            (fg-region                 "#FFFFFF")
            (fg-heading-0              "#82aaff")
            (fg-heading-1              "#82aaff")
            (fg-heading-2              "#c792ea")
            (fg-heading-3              "#bb80b3")
            (fg-heading-4              "#a1bfff")
            (fg-prose-verbatim         "#c3e88d")
            (bg-prose-block-contents   "#232635")
            (fg-prose-block-delimiter  "#676E95")
            (bg-prose-block-delimiter  bg-prose-block-contents)
            (accent-1                  "#79a8ff")
            (keyword                   "#89DDFF")
            (builtin                   "#82aaff")
            (comment                   "#676E95")
            (string                    "#c3e88d")
            (fnname                    "#82aaff")
            (type                      "#c792ea")
            (variable                  "#ffcb6b")
            (docstring                 "#8d92af")
            (constant                  "#f78c6c")
            (bg-term-black             "#4c5374")
            (fg-term-black             "#4c5374")
            (bg-term-black-bright      "#676E95")
            (fg-term-black-bright      "#676E95")
            (bg-term-red               "#EF5350")
            (fg-term-red               "#EF5350")
            (bg-term-red-bright        "#ff5572")
            (fg-term-red-bright        "#ff5572")
            (bg-term-green             "#a9c77d")
            (fg-term-green             "#a9c77d")
            (bg-term-green-bright      "#C3E88D")
            (fg-term-green-bright      "#C3E88D")
            (bg-term-yellow            "#FFCA28")
            (fg-term-yellow            "#FFCA28")
            (bg-term-yellow-bright     "#ffcb6b")
            (fg-term-yellow-bright     "#ffcb6b")
            (bg-term-blue              "#64B5F6")
            (fg-term-blue              "#64B5F6")
            (bg-term-blue-bright       "#82AAFF")
            (fg-term-blue-bright       "#82AAFF")
            (bg-term-magenta           "#C792EA")
            (fg-term-magenta           "#C792EA")
            (bg-term-magenta-bright    "#d1aaff")
            (fg-term-magenta-bright    "#d1aaff")
            (bg-term-cyan              "#89DDFF")
            (fg-term-cyan              "#89DDFF")
            (bg-term-cyan-bright       "#80CBC4")
            (fg-term-cyan-bright       "#80CBC4")
            (bg-term-white             "#bfc7d5")
            (fg-term-white             "#bfc7d5")
            (bg-term-white-bright      "#ffffff")
            (fg-term-white-bright      "#ffffff"))))

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
(rc/apply-palenight-style)
(load-theme 'modus-vivendi-tinted t)
(add-hook 'modus-themes-after-load-theme-hook #'rc/clear-background-color)
(rc/style-window-dividers)

(provide 'theme-rc)
