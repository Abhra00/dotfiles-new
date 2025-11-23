;;; eshell-rc.el --- Custom Eshell configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Custom Eshell setup with shared history, custom prompt, and utilities
;; THANKS!: https://github.com/LionyxML/emacs-solo
;;; Code:

(require 'eshell)
(require 'vc)
(require 'vc-git)

;; Corfu settings
(add-hook 'eshell-mode-hook
          (lambda ()
            (corfu-mode -1)))

;;; History Settings
(setq eshell-history-size 100000)
(setq eshell-hist-ignoredups t)
(setq eshell-history-file-name (expand-file-name "eshell/history" user-emacs-directory))

;;; Shared History Functions
(defun rc/eshell--collect-all-history ()
  "Return a list of all eshell history entries from all buffers and disk."
  (let ((history-from-buffers
         (cl-loop for buf in (buffer-list)
                  when (with-current-buffer buf (derived-mode-p 'eshell-mode))
                  append (with-current-buffer buf
                           (when (boundp 'eshell-history-ring)
                             (ring-elements eshell-history-ring)))))
        (history-from-file
         (when (file-exists-p eshell-history-file-name)
           (with-temp-buffer
             (insert-file-contents eshell-history-file-name)
             (split-string (buffer-string) "\n" t)))))
    (seq-uniq (append history-from-buffers history-from-file))))

(defun rc/eshell--save-merged-history ()
  "Save all eshell buffer histories merged into `eshell-history-file-name`."
  (let ((all-history (rc/eshell--collect-all-history)))
    (with-temp-file eshell-history-file-name
      (insert (mapconcat #'identity all-history "\n")))))

(add-hook 'kill-emacs-hook #'rc/eshell--save-merged-history)

(add-hook 'eshell-mode-hook
          (lambda ()
            (eshell-read-history)))

;;; Custom Welcome Banner
(setopt eshell-banner-message
        (concat
         (propertize "   Welcome to the Emacs EShell  \n\n" 'face '(:weight bold :foreground "#A7C080"))
         (propertize " C-c t" 'face '(:foreground "#D699B6" :weight bold)) " - toggles between prompts (full / minimum)\n"
         (propertize " C-c T" 'face '(:foreground "#D699B6" :weight bold)) " - toggles between full prompts (lighter / heavier)\n"
         (propertize " C-c l" 'face '(:foreground "#D699B6" :weight bold)) " - searches history\n"
         (propertize " C-l  " 'face '(:foreground "#D699B6" :weight bold)) " - clears scrolling\n\n"))

;;; Disable Conservative Scrolling
(defun rc/reset-scrolling-vars-for-term ()
  "Locally reset scrolling behavior in term-like buffers."
  (setq-local scroll-conservatively 0)
  (setq-local scroll-margin 0))

(add-hook 'eshell-mode-hook #'rc/reset-scrolling-vars-for-term)

;;; History Search Function
(defun rc/eshell-pick-history ()
  "Show a unified and unique Eshell history from all open sessions and the history file.
Pre-fills the minibuffer with current Eshell input (from prompt to point)."
  (interactive)
  (unless (derived-mode-p 'eshell-mode)
    (user-error "This command must be called from an Eshell buffer"))
  (let* (;; Safely get current input from prompt to point
         (bol (save-excursion (eshell-bol) (point)))
         (eol (point))
         (current-input (buffer-substring-no-properties bol eol))

         ;; Path to Eshell history file
         (history-file (expand-file-name eshell-history-file-name
                                         eshell-directory-name))

         ;; Read from history file
         (history-from-file
          (when (file-exists-p history-file)
            (with-temp-buffer
              (insert-file-contents-literally history-file)
              (split-string (buffer-string) "\n" t))))

         ;; Read from in-memory Eshell buffers
         (history-from-rings
          (cl-loop for buf in (buffer-list)
                   when (with-current-buffer buf (derived-mode-p 'eshell-mode))
                   append (with-current-buffer buf
                            (when (bound-and-true-p eshell-history-ring)
                              (ring-elements eshell-history-ring)))))

         ;; Deduplicate and sort
         (all-history (reverse
                       (seq-uniq
                        (seq-filter (lambda (s) (and s (not (string-empty-p s))))
                                    (append history-from-rings history-from-file)))))

         ;; Prompt user with current input as initial suggestion
         (selection (completing-read "Eshell History: " all-history
                                     nil t current-input)))

    (when selection
      ;; Replace current input with selected history entry
      (delete-region bol eol)
      (insert selection))))

;;; Syntax Highlighting for Cat
(defun eshell/cat-with-syntax-highlighting (filename)
  "Like cat(1) but with syntax highlighting."
  (let ((existing-buffer (get-file-buffer filename))
        (buffer (find-file-noselect filename)))
    (eshell-print
     (with-current-buffer buffer
       (if (fboundp 'font-lock-ensure)
           (font-lock-ensure)
         (with-no-warnings
           (font-lock-fontify-buffer)))
       (let ((contents (buffer-string)))
         (remove-text-properties 0 (length contents) '(read-only nil) contents)
         contents)))
    (unless existing-buffer
      (kill-buffer buffer))
    nil))

(advice-add 'eshell/cat :override #'eshell/cat-with-syntax-highlighting)

;;; Local Keybindings
(add-hook 'eshell-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c l") #'rc/eshell-pick-history)
            (local-set-key (kbd "C-c t") #'rc/toggle-eshell-prompt)
            (local-set-key (kbd "C-c T") #'rc/toggle-eshell-prompt-resource-intensive)
            (local-set-key (kbd "C-l")
                           (lambda ()
                             (interactive)
                             (eshell/clear 1)))))

;;; Custom Prompt Variables
(defvar rc/eshell-full-prompt t
  "When non-nil, show the full Eshell prompt. When nil, show minimal prompt.")

(defvar rc/eshell-full-prompt-resource-intensive nil
  "When non-nil, and rc/eshell-full-prompt t. Also show slower operations.")

(defvar rc/eshell-lambda-symbol "  λ "
  "Symbol used for the minimal Eshell prompt.")

(defun rc/toggle-eshell-prompt ()
  "Toggle between full and minimal Eshell prompt."
  (interactive)
  (setq rc/eshell-full-prompt (not rc/eshell-full-prompt))
  (message "Eshell prompt: %s"
           (if rc/eshell-full-prompt "full" "minimal"))
  (when (derived-mode-p 'eshell-mode)
    (eshell-reset)))

(defun rc/toggle-eshell-prompt-resource-intensive ()
  "Toggle between full and minimal Eshell prompt."
  (interactive)
  (setq rc/eshell-full-prompt-resource-intensive
        (not rc/eshell-full-prompt-resource-intensive))
  (message "Eshell prompt: %s"
         (if rc/eshell-full-prompt-resource-intensive "lighter" "heavier"))
  (when (derived-mode-p 'eshell-mode)
    (eshell-reset)))

;;; Color Variables (gruber darker)
(defvar eshell-rc/color-bg-dark "#1E2326")
(defvar eshell-rc/color-bg-mid "#495156")
(defvar eshell-rc/color-fg-user "#D699B6")
(defvar eshell-rc/color-fg-host "#E67E80")
(defvar eshell-rc/color-fg-dir "#A7C080")
(defvar eshell-rc/color-fg-git "#DBBC7F")

;;; Icon Definitions
(defvar rc/eshell-icons
  '((arrow-left        . "")
    (arrow-right       . "")
    (success           . "")
    (failure           . "")
    (user-local        . "")
    (user-remote       . "")
    (host-local        . "")
    (host-remote       . "")
    (time              . "")
    (folder            . "")
    (branch            . "")
    (modified          . " ")
    (untracked         . " ")
    (conflict          . " ")
    (git-merge         . " ")
    (git-ahead         . " ")
    (git-behind        . " "))
  "Alist of all icons used in the Eshell prompt (nerd font).")

;;; Git Info Caching
(defvar rc/git-cache nil)
(defvar rc/git-cache-dir nil)
(defvar rc/git-cache-time 0)

(defun rc/git-info ()
  "Return cached Git info, with debug messages."
  (let ((root (ignore-errors (vc-git-root default-directory)))
        (now (float-time)))
    (if (or (not root)
            (not (numberp rc/git-cache-time))
            (not rc/git-cache)
            (not (equal root rc/git-cache-dir))
            (> (- now (or rc/git-cache-time 0)) 5))
        (progn
          (setq rc/git-cache-time now
                rc/git-cache-dir root)
          (setq rc/git-cache
                (when root
                  (let* ((out (shell-command-to-string "git status --porcelain=v2 --branch 2>/dev/null"))
                         (lines (split-string out "\n" t))
                         (ahead 0)
                         (behind 0)
                         (modified 0)
                         (untracked 0)
                         (conflicts 0)
                         (branch nil))

                    (dolist (l lines)
                      (cond
                       ((string-match "^#? *branch\\.head \\(.+\\)" l)
                        (setq branch (match-string 1 l)))
                       ((string-match "^#? *branch\\.ab \\+\\([0-9]+\\) -\\([0-9]+\\)" l)
                        (setq ahead (string-to-number (match-string 1 l)))
                        (setq behind (string-to-number (match-string 2 l))))
                       ((string-match "^1 " l) (cl-incf modified))
                       ((string-match "^\\?\\?" l) (cl-incf untracked))
                       ((string-match "^u " l) (cl-incf conflicts))))

                    (list :branch (or branch "HEAD")
                          :ahead ahead
                          :behind behind
                          :modified modified
                          :untracked untracked
                          :conflicts conflicts)))))
      (progn
        rc/git-cache))))

;;; Custom Prompt Function
(setopt eshell-prompt-function
        (lambda ()
          (if rc/eshell-full-prompt
              ;; Full-blown prompt
              (concat
               (propertize
                (assoc-default 'arrow-left rc/eshell-icons) 'face `(:foreground ,eshell-rc/color-bg-dark))

               (propertize
                (if (> eshell-last-command-status 0)
                    (concat " " (assoc-default 'failure rc/eshell-icons)  " ")
                  (concat " " (assoc-default 'success rc/eshell-icons)  " "))
                'face `(:background ,eshell-rc/color-bg-dark))

               (propertize (concat (number-to-string eshell-last-command-status) " ")
                           'face `(:background ,eshell-rc/color-bg-dark))

               (propertize (assoc-default 'arrow-right rc/eshell-icons)
                           'face `(:foreground ,eshell-rc/color-bg-dark :background ,eshell-rc/color-bg-mid))

               (propertize (let ((remote-user (file-remote-p default-directory 'user))
                                 (is-remote (file-remote-p default-directory)))
                             (concat
                              (if is-remote
                                  (concat (assoc-default 'user-remote rc/eshell-icons)  " ")
                                (concat (assoc-default 'user-local rc/eshell-icons)  " "))
                              (or remote-user (user-login-name))
                              " "))
                           'face `(:foreground ,eshell-rc/color-fg-user
                                               :background ,eshell-rc/color-bg-mid))

               (propertize (assoc-default 'arrow-right rc/eshell-icons) 'face
                           `(:foreground ,eshell-rc/color-bg-mid :background ,eshell-rc/color-bg-dark))

               (let ((remote-host (file-remote-p default-directory 'host))
                     (is-remote (file-remote-p default-directory)))
                 (propertize (concat (if is-remote
                                         (concat " " (assoc-default 'host-remote rc/eshell-icons)  " ")
                                       (concat " " (assoc-default 'host-local rc/eshell-icons)  " "))
                                     (or remote-host (system-name)) " ")
                             'face `(:background ,eshell-rc/color-bg-dark  :foreground ,eshell-rc/color-fg-host)))

               (propertize (assoc-default 'arrow-right rc/eshell-icons) 'face
                           `(:foreground ,eshell-rc/color-bg-dark :background ,eshell-rc/color-bg-mid))

               (propertize (concat " " (assoc-default 'time rc/eshell-icons)  " "
                                   (format-time-string "%H:%M:%S" (current-time)) " ")
                           'face `(:foreground ,eshell-rc/color-fg-user :background ,eshell-rc/color-bg-mid))

               (propertize (assoc-default 'arrow-right rc/eshell-icons)
                           'face `(:foreground ,eshell-rc/color-bg-mid :background ,eshell-rc/color-bg-dark))

               (propertize (concat " " (assoc-default 'folder rc/eshell-icons)  " "
                                   (if (>= (length (eshell/pwd)) 40)
                                       (concat "…" (car (last (butlast (split-string (eshell/pwd) "/") 0))))
                                     (abbreviate-file-name (eshell/pwd))) " ")
                           'face `(:background ,eshell-rc/color-bg-dark :foreground ,eshell-rc/color-fg-dir))

               (propertize (concat (assoc-default 'arrow-right rc/eshell-icons) "\n")
                           'face `(:foreground ,eshell-rc/color-bg-dark))

               (when-let* ((info (rc/git-info))
                           (branch (plist-get info :branch)))
                 (concat
                  (propertize (assoc-default 'arrow-left rc/eshell-icons)
                              'face `(:foreground ,eshell-rc/color-bg-dark))
                  (propertize
                   (concat
                    (concat " " (assoc-default 'branch rc/eshell-icons) " " branch " ")
                    (when rc/eshell-full-prompt-resource-intensive
                      (let ((ahead (plist-get info :ahead))
                            (behind (plist-get info :behind))
                            (modified (plist-get info :modified))
                            (untracked (plist-get info :untracked))
                            (conflicts (plist-get info :conflicts)))
                        (concat
                         (when (> ahead 0)
                           (format (concat " " (assoc-default 'git-ahead rc/eshell-icons) "%d") ahead))
                         (when (> behind 0)
                           (format (concat " " (assoc-default 'git-behind rc/eshell-icons) "%d") behind))
                         (when (and (> ahead 0) (> behind 0))
                           (concat " " (assoc-default 'git-merge rc/eshell-icons)))
                         (when (> modified 0)
                           (format (concat " " (assoc-default 'modified rc/eshell-icons) "%d") modified))
                         (when (> untracked 0)
                           (format (concat " " (assoc-default 'untracked rc/eshell-icons) "%d") untracked))
                         (when (> conflicts 0)
                           (format (concat " " (assoc-default 'conflict rc/eshell-icons) "%d") conflicts))
                         " "))))
                   'face `(:background ,eshell-rc/color-bg-dark :foreground ,eshell-rc/color-fg-git))
                  (propertize (concat (assoc-default 'arrow-right rc/eshell-icons) "\n")
                              'face `(:foreground ,eshell-rc/color-bg-dark))))

               (propertize rc/eshell-lambda-symbol 'face font-lock-keyword-face))

            ;; Minimal prompt
            (propertize rc/eshell-lambda-symbol 'face font-lock-keyword-face))))

(setq eshell-prompt-regexp rc/eshell-lambda-symbol)

(provide 'eshell-rc)
;;; eshell-config.el ends here
