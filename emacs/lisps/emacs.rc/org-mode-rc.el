;;; org-mode-rc.el --- Org mode configuration -*- lexical-binding: t; -*-

(global-set-key (kbd "C-x a") 'org-agenda)
(global-set-key (kbd "C-c C-x j") #'org-clock-goto)
(setq org-agenda-files (list "~/Documents/Agenda/"))
(setq org-export-backends '(md))

(defun rc/org-increment-move-counter ()
  (interactive)
  (cl-flet ((default (x d)
              (if x x d)))
    (let* ((point (point))
           (move-counter-name "MOVE_COUNTER")
           (move-counter-value (-> (org-entry-get point move-counter-name)
                                   (default "0")
                                   (string-to-number)
                                   (1+))))
      (org-entry-put point move-counter-name
                     (number-to-string move-counter-value))))
  nil)

(defun rc/org-get-heading-name ()
  (nth 4 (org-heading-components)))

(defun rc/org-kill-heading-name-save ()
  (interactive)
  (let ((heading-name (rc/org-get-heading-name)))
    (kill-new heading-name)
    (message "Kill \"%s\"" heading-name)))

(global-set-key (kbd "C-x p w") 'rc/org-kill-heading-name-save)

(setq org-agenda-custom-commands
      '(("u" "Unscheduled" tags "+personal-SCHEDULED={.+}-DEADLINE={.+}/!+TODO"
         ((org-agenda-sorting-strategy '(priority-down))))
        ("p" "Personal" ((agenda "" ((org-agenda-tag-filter-preset (list "+personal"))))))
        ("w" "Work" ((agenda "" ((org-agenda-tag-filter-preset (list "+work"))))))
        ))

;;; org-cliplink
(rc/require 'org-cliplink)
(global-set-key (kbd "C-x p i") 'org-cliplink)

(defun rc/cliplink-task ()
  (interactive)
  (org-cliplink-retrieve-title
   (substring-no-properties (current-kill 0))
   '(lambda (url title)
      (insert (if title
                  (concat "* TODO " title
                          "\n  [[" url "][" title "]]")
                (concat "* TODO " url
                        "\n  [[" url "]]"))))))

(global-set-key (kbd "C-x p t") 'rc/cliplink-task)

;;; org-capture
(setq org-capture-templates
      '(("p" "Capture task" entry (file "~/Documents/Agenda/Tasks.org")
         "* TODO %?\n  SCHEDULED: %t\n")
        ("K" "Cliplink capture task" entry (file "~/Documents/Agenda/Tasks.org")
         "* TODO %(org-cliplink-capture) \n  SCHEDULED: %t\n" :empty-lines 1)))

(define-key global-map "\C-cc" 'org-capture)

;;; modern org mode
(rc/require 'org-modern)

;;; org Mode visual enhancements
(setq
 ;;; editing behavior

 org-auto-align-tags nil
 org-tags-column 0
 org-fold-catch-invisible-edits 'show-and-error
 org-special-ctrl-a/e t
 org-insert-heading-respect-content t
 ;;; appearance

 org-hide-emphasis-markers t
 org-pretty-entities t
 org-agenda-tags-column 0
 org-ellipsis "…")  ;; Display this instead of '...'

;; when org-modern is ready, set org modern settings
(with-eval-after-load 'org-modern
  (setq org-modern-star 'replace
        org-modern-replace-stars
        ["◈" "◆" "★" "♠" "✸" "✿" "❀" "∙"])
  (setq org-modern-todo-faces
        '(("TODO" . org-todo)
          ("DONE" . org-done)))
  (set-face-attribute 'org-modern-symbol nil :family "JetbrainsMono Nerd Font Propo"))

;;; enable org-modern in all Org buffers
(global-org-modern-mode)

;;; style agenda views
(add-hook 'org-agenda-finalize-hook #'org-modern-agenda)

(provide 'org-mode-rc)
;;; org-mode-rc.el ends here
