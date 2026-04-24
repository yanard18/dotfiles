;;; ==========================================
;;; core ui & behavior
;;; ==========================================
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode 1)
(global-display-line-numbers-mode 1)
(global-auto-revert-mode t)

(setq display-line-numbers-type 'visual
      inhibit-startup-screen t
      initial-scratch-message ""
      initial-major-mode 'lisp-interaction-mode) 

;;; --- tabs & indentation ---
(setq-default indent-tabs-mode t       ;; use tabs instead of spaces
              tab-always-indent nil    ;; tab key inserts real tab when appropriate
              tab-width 4              ;; visual width of a tab
              standard-indent 4        ;; indentation step
              backward-delete-char-untabify nil) ;; don't turn tabs into spaces on delete

(defun my-c-hook ()
  (c-set-style "linux")
  (setq c-basic-offset 4)
  (setq-local evil-shift-width 4))

(add-hook 'c-mode-hook 'my-c-hook)
(add-hook 'c++-mode-hook 'my-c-hook)

;;; --- auto save & backup ---
(setq backup-directory-alist '(("." . "~/.emacs.d/backups/"))
      auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save/" t))
      create-lockfiles nil) ;; disable lock files (.#filename)

(make-directory "~/.emacs.d/backups/" t)
(make-directory "~/.emacs.d/auto-save/" t)

;;; ==========================================
;;; package management
;;; ==========================================
(require 'package)
(setq package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

;; Avoid typing :ensure t for every package
(setq use-package-always-ensure t)

;;; --- theme ---
(setq custom-file "~/.emacs.d/emacs.custom")
(load custom-file 'noerror)

(use-package gruber-darker-theme
  :config
  (load-theme 'gruber-darker t))

;;; ==========================================
;;; LSP / Eglot (C++ Intelligence)
;;; ==========================================
(use-package eglot
  :ensure nil ;; Built-in, override auto-ensure
  :hook ((c-mode . eglot-ensure)
         (c++-mode . eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs '((c++-mode c-mode) . ("clangd"))))

;;; ==========================================
;;; evil mode (vim emulation)
;;; ==========================================
(use-package evil
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil)
  :config
  (evil-mode 1)
  (setq evil-backspace-join-lines nil
        evil-want-visual-char-semi-at-end-of-line t)
  (define-key evil-insert-state-map [backspace] 'backward-delete-char)
  (define-key evil-motion-state-map (kbd "j") 'evil-next-visual-line)
  (define-key evil-motion-state-map (kbd "k") 'evil-previous-visual-line))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;;; ==========================================
;;; yank & undo
;;; ==========================================
(setq select-enable-clipboard t
      select-enable-primary t
      save-interprogram-paste-before-kill t
      yank-pop-change-selection t)

(use-package undo-tree
  :init
  (global-undo-tree-mode 1)
  :config
  (setq undo-tree-auto-save-history nil)
  (evil-set-undo-system 'undo-tree))

;;; ==========================================
;;; compilation colors
;;; ==========================================
(require 'ansi-color)
(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

;;; ==========================================
;;; org mode
;;; ==========================================
(use-package org
  :hook (org-mode . visual-line-mode)
  :custom
  (org-hide-emphasis-markers t)
  (org-hide-drawer-startup t)
  (org-return-follows-link t)
  (org-src-window-setup 'current-window) 
  (org-edit-src-content-indentation 0)
  (org-src-preserve-indentation t)
  :config
  (require 'org-tempo)
  (setf (cdr (assoc 'file org-link-frame-setup)) 'find-file))

(use-package org-roam
  :custom
  (org-roam-directory (file-truename "~/RoamNotes"))
  (org-roam-file-exclude-regexp "\\.gpg$")
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture))
  :config
  (when (file-directory-p org-roam-directory)
	(org-roam-db-autosync-mode)))

(use-package org-appear
  :hook (org-mode . org-appear-mode)
  :custom
  (org-appear-autolinks t)
  (org-appear-autosubmarkers t)
  (org-appear-autokeywords t))

(use-package org-modern
  :hook (org-mode . org-modern-mode)
  :custom
  (org-modern-star '("◉" "○" "◈" "◇" "⁖"))
  (org-modern-table nil)
  (org-modern-tag t)
  (org-modern-priority t)
  (org-modern-keyword t))


;;; ==========================================
;;; encryption (epa)
;;; ==========================================
(require 'epa-file)
(epa-file-enable)
(setq epa-file-encrypt-to nil 
      epa-file-select-keys nil 
      epg-pinentry-mode 'loopback
      epa-file-cache-passphrase-for-symmetric-encryption t)

;;; ==========================================
;;; completion framework
;;; ==========================================
(use-package consult)

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package vertico
  :init
  (vertico-mode 1)
  :bind (:map vertico-map
              ("C-j" . vertico-next)
              ("C-k" . vertico-previous)
              ("C-l" . vertico-exit))
  :config
  (setq minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook 'cursor-intangible-mode))

;;; ==========================================
;;; git (magit)
;;; ==========================================
(use-package magit
  :custom
  ;; Optional: Makes Magit open in the current window rather than splitting
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;;; ==========================================
;;; markdown
;;; ==========================================
(use-package markdown-mode
  :mode ("\\.\\(?:md\\|markdown\\|mkd\\|mdown\\|mkdn\\|mdwn\\)\\'" . markdown-mode)
  :custom
  (markdown-command "multimarkdown")
  (markdown-fontify-code-blocks-natively t)
  (markdown-header-scaling t)
  (markdown-hide-markup nil)
  :hook (markdown-mode . visual-line-mode))

;;; ==========================================
;;; faces (org & markdown)
;;; ==========================================
(custom-set-faces
 ;; org blocks
 '(org-block ((t (:background "#1e1e1e" :extend t :inherit fixed-pitch))))
 '(org-block-begin-line ((t (:background "#252525" :foreground "#51afef" :extend t :inherit fixed-pitch))))
 '(org-block-end-line ((t (:background "#252525" :foreground "#51afef" :extend t :inherit fixed-pitch))))
 ;; org - code & verbatim
 '(org-code ((t (:background "#2e2e2e" :foreground "#ce9178" :box (:line-width 1 :color "#3e3e3e") :inherit fixed-pitch))))
 '(org-verbatim ((t (:inherit org-code :family "monospace"))))
 '(markdown-inline-code-face ((t (:inherit org-code :family "monospace"))))
 ;; markdown
 '(markdown-header-face-1 ((t (:inherit bold :foreground "white" :height 1.4))))
 '(markdown-header-face-2 ((t (:inherit bold :foreground "white" :height 1.2))))
 '(markdown-header-face-3 ((t (:inherit bold :foreground "white" :height 1.1))))
 '(markdown-code-face ((t (:background "#1e1e1e" :extend t :inherit fixed-pitch :family "monospace")))))

;;; ==========================================
;;; leader key (general.el)
;;; ==========================================
(use-package general
  :config
  (general-create-definer my-leader-def
    :states '(normal visual motion emacs)
    :keymaps 'override
    :prefix "SPC"
    :non-normal-prefix "M-SPC")

  (my-leader-def
    "b"  'consult-buffer
    "f"  'consult-find
    "s"  'consult-line
    "g"  'consult-grep
    "i"  'ibuffer
    "nf" 'org-roam-node-find
    "ni" 'org-roam-node-insert
    "nc" 'org-roam-capture
    "p"  'consult-yank-pop
    "u"  'undo-tree-visualize
    "mg" 'magit-status
    "cr" 'eglot-rename
    "cu" 'xref-find-references
    "ca" 'eglot-code-actions)
    
  (general-define-key
   :keymaps 'org-mode-map
   :states '(normal motion)
   "RET" 'org-open-at-point))
