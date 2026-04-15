;;; ==========================================
;;; core ui & behavior
;;; ==========================================
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode 1)
(setq display-line-numbers-type 'visual)
(global-display-line-numbers-mode 1)
(global-auto-revert-mode t)
(setq inhibit-startup-screen t)
(setq initial-scratch-message "")
(setq initial-major-mode 'lisp-interaction-mode) 

;;; --- tabs & indentation ---
(setq-default indent-tabs-mode t)      ;; use tabs instead of spaces
(setq-default tab-always-indent nil)   ;; tab key inserts real tab when appropriate
(setq-default tab-width 4)             ;; visual width of a tab
(setq-default standard-indent 4)       ;; indentation step
(setq-default backward-delete-char-untabify nil) ;; don't turn tabs into spaces on delete

(defun c-hook ()
  (c-set-style "linux")
  (setq indent-tabs-mode t)
  (setq c-basic-offset 4)
  (setq tab-width 4)
  (setq-local evil-shift-width 4)
  (setq c-tab-always-indent nil))

(add-hook 'c-mode-hook 'c-hook)
(add-hook 'c++-mode-hook 'c-hook)

;;; --- auto save & backup ---
(setq backup-directory-alist '(("." . "~/.emacs.d/backups/")))
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save/" t)))
(setq create-lockfiles nil) ;; disable lock files (.#filename)
(make-directory "~/.emacs.d/backups/" t)
(make-directory "~/.emacs.d/auto-save/" t)

;;; ==========================================
;;; package management
;;; ==========================================
(require 'package)
(setq package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

;;; --- theme ---
(setq custom-file "~/.emacs.d/emacs.custom")
(load custom-file 'noerror)

(use-package gruber-darker-theme
  :ensure t
  :config
  (load-theme 'gruber-darker t))

;;; ==========================================
;;; evil mode (vim emulation)
;;; ==========================================
(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t) 
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1)
  (setq evil-backspace-join-lines nil)
  (setq evil-want-visual-char-semi-at-end-of-line t)
  ;; fix backspace in insert mode
  (define-key evil-insert-state-map [backspace] 'backward-delete-char)
  ;; global visual line navigation (moved out of org-mode scope)
  (define-key evil-motion-state-map (kbd "j") 'evil-next-visual-line)
  (define-key evil-motion-state-map (kbd "k") 'evil-previous-visual-line))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

;;; ==========================================
;;; leader key (general.el)
;;; ==========================================
(use-package general
  :ensure t
  :config
  (general-create-definer my-leader-def
    :states '(normal visual motion emacs)
    :keymaps 'override ;; ensures spc works even in dired/magit overriding default modes
    :prefix "spc"
    :non-normal-prefix "m-spc")

  ;; single source of truth for core actions (removed m-s overlapping logic)
  (my-leader-def
    "b" 'consult-buffer
    "f" 'consult-find
    "s" 'consult-line
    "g" 'consult-grep
    "i" 'ibuffer))

;;; ==========================================
;;; colors
;;; ==========================================
(require 'ansi-color)
(defun my-colorize-compilation-buffer ()
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region compilation-filter-start (point-max))))
(add-hook 'compilation-filter-hook 'my-colorize-compilation-buffer)

;;; ==========================================
;;; org mode
;;; ==========================================
(use-package org
  :hook (org-mode . visual-line-mode)
  :config
  (require 'org-tempo)
  (setq org-return-follows-link t)
  (setf (cdr (assoc 'file org-link-frame-setup)) 'find-file)
  (evil-define-key 'motion org-mode-map (kbd "ret") 'org-return)
  (evil-define-key 'normal org-mode-map (kbd "ret") 'org-return))

(setq org-hide-emphasis-markers t)

(use-package org-appear
  :ensure t
  :hook (org-mode . org-appear-mode)
  :config
  ;; this makes it work for links, bold, code, etc.
  (setq org-appear-autolinks t
        org-appear-autosubmarkers t
        org-appear-autokeywords t))

(use-package org-modern
  :ensure t
  :hook (org-mode . org-modern-mode)
  :config
  (setq
   ;; edit these to your liking
   org-modern-star '("◉" "○" "◈" "◇" "⁖")
   org-modern-table nil   ; set to t if you want fancy tables
   org-modern-tag t
   org-modern-priority t
   org-modern-keyword t))

;; center the text and set 80 col wdith
(use-package visual-fill-column
  :ensure t
  :hook (org-mode . visual-fill-column-mode)
  :custom
  (fill-column 80)
  (visual-fill-column-width 80)
  (visual-fill-column-center-text t))


(setq org-src-window-setup 'current-window) ;; edit code in the same window

;;; ==========================================
;;; completion framework
;;; ==========================================
(use-package consult
  :ensure t
  ;; bindings cleared: rely on your general 'spc' bindings to prevent overlap
  )

(use-package vertico
  :ensure t
  :init
  (vertico-mode 1)
  :bind (:map vertico-map
              ("c-j" . vertico-next)
              ("c-k" . vertico-previous)
              ("c-l" . vertico-exit)) ;; note: usually ret is exit, but leaving c-l per your preference
  :config
  ;; do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook 'cursor-intangible-mode))


;;; ==========================================
;;; markdown
;;; ==========================================

(use-package markdown-mode
  :ensure t
  :mode ("\\.\\(?:md\\|markdown\\|mkd\\|mdown\\|mkdn\\|mdwn\\)\\'" . markdown-mode)
  :config
  (setq markdown-command "multimarkdown")
  (setq markdown-fontify-code-blocks-natively t)
  (setq markdown-header-scaling t)
  (setq markdown-hide-markup nil) 
  (add-hook 'markdown-mode-hook
            (lambda ()
              (setq indent-tabs-mode t)
              (setq tab-width 4)
              (visual-line-mode 1))))

;;; ==========================================
;;; faces (org & markdown)
;;; ==========================================
(custom-set-faces
 ;; org blocks
 '(org-block ((t (:background "#1e1e1e" :extend t :inherit fixed-pitch))))
 '(org-block-begin-line ((t (:background "#252525" :foreground "#51afef" :extend t :inherit fixed-pitch))))
 '(org-block-end-line ((t (:background "#252525" :foreground "#51afef" :extend t :inherit fixed-pitch))))
 ;; org - code & verbatim (button effect)
 '(org-code ((t (:background "#2e2e2e" :foreground "#ce9178" :box (:line-width 1 :color "#3e3e3e") :inherit fixed-pitch))))
 '(org-verbatim ((t (:inherit org-code :family "monospace")))) ;; inherits everything from org-code
 '(markdown-inline-code-face ((t (:inherit org-code :family "monospace")))) ;; reuse the same look for markdown

 ;; markdown
 '(markdown-header-face-1 ((t (:inherit bold :foreground "white" :height 1.4))))
 '(markdown-header-face-2 ((t (:inherit bold :foreground "white" :height 1.2))))
 '(markdown-header-face-3 ((t (:inherit bold :foreground "white" :height 1.1))))
 '(markdown-code-face ((t (:background "#1e1e1e" :extend t :inherit fixed-pitch :family "monospace"))))
)
