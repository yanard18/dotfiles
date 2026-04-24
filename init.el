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
;;; LSP / Eglot (C++ Intelligence)
;;; ==========================================

(use-package eglot
  :ensure nil ;; Built-in, no need to download if on Emacs 29+
  :hook ((c-mode . eglot-ensure)
         (c++-mode . eglot-ensure))
  :config
  ;; This helps Eglot find the clangd server you just installed
  (add-to-list 'eglot-server-programs
               '((c++-mode c-mode) . ("clangd")))
  
  ;; Make the leader key work for renaming and actions
  (my-leader-def
    "cr" 'eglot-rename
	"cu" 'xref-find-references
    "ca" 'eglot-code-actions))

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
;;; yank 
;;; ==========================================

(setq select-enable-clipboard t)
(setq select-enable-primary t)
(setq save-interprogram-paste-before-kill t)
(setq yank-pop-change-selection t)

;;; ==========================================
;;; colors
;;; ==========================================
(require 'ansi-color)
(defun my-colorize-compilation-buffer ()
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region compilation-filter-start (point-max))))
(add-hook 'compilation-filter-hook 'my-colorize-compilation-buffer)

(use-package undo-tree
  :ensure t
  :init
  (global-undo-tree-mode 1)
  :config
  (setq undo-tree-auto-save-history nil)
  (evil-set-undo-system 'undo-tree))

;;; ==========================================
;;; org mode
;;; ==========================================
(use-package org
  :hook (org-mode . visual-line-mode)
  :config
  (require 'org-tempo)
  (setq org-hide-emphasis-markers t)
  (setq org-hide-drawer-startup t)
  (setq org-return-follows-link t)
  (setf (cdr (assoc 'file org-link-frame-setup)) 'find-file)
  (evil-define-key 'motion org-mode-map (kbd "ret") 'org-return)
  (evil-define-key 'normal org-mode-map (kbd "ret") 'org-return))



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

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (file-truename "~/RoamNotes")) 
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture))
  :config
  (setq org-roam-file-exclude-regexp "\\.gpg$")
  (org-roam-db-autosync-mode))

(general-define-key
 :keymaps 'org-mode-map
 :states '(normal motion)
 "RET" 'org-open-at-point)

;; edit code in the same window
(setq org-src-window-setup 'current-window) 

;; Stop Org from indenting the content of source blocks
(setq org-edit-src-content-indentation 0)

;; Ensure that what you see in the edit buffer is exactly what is in the Org file
(setq org-src-preserve-indentation t)

;; Agenda (this might be slow when have so much notes)
(setq org-agenda-files (directory-files-recursively "~/RoamNotes/" "\\.org$"))

;;; ==========================================
;;; encryption (epa)
;;; ==========================================
(require 'epa-file)
(epa-file-enable)
(setq epa-file-encrypt-to nil)  ;; Forces symmetric encryption (password only)
(setq epa-file-select-keys nil) ;; Skips the "select public key" prompt
(setq epg-pinentry-mode 'loopback)
(setq epa-file-cache-passphrase-for-symmetric-encryption t)

;;; ==========================================
;;; completion framework
;;; ==========================================
(use-package consult
  :ensure t
  ;; bindings cleared: rely on your general 'spc' bindings to prevent overlap
  )

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  ;; Keep basic completion for files so remote paths or specific file setups don't break
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package vertico
  :ensure t
  :init
  (vertico-mode 1)
  :bind (:map vertico-map
              ("C-j" . vertico-next)
              ("C-k" . vertico-previous)
              ("C-l" . vertico-exit)) ;; note: usually ret is exit, but leaving c-l per your preference
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

;;; ==========================================
;;; leader key (general.el)
;;; ==========================================
(use-package general
  :ensure t
  :config
  (general-create-definer my-leader-def
    :states '(normal visual motion emacs)
    :keymaps 'override
    :prefix "SPC"
    :non-normal-prefix "M-SPC")

  (my-leader-def
    "b" 'consult-buffer
    "f" 'consult-find
    "s" 'consult-line
	"g" 'consult-grep
	"i" 'ibuffer
	"nf" 'org-roam-node-find
    "ni" 'org-roam-node-insert
    "nc" 'org-roam-capture
	"p" 'consult-yank-pop'
	"u" 'undo-tree-visualize))
