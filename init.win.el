;;; ==========================================
;;; core ui & behavior
;;; ==========================================
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode 1)
(setq display-line-numbers-type 'visual)
(global-display-line-numbers-mode 1)
(global-auto-revert-mode t)

;; Fonts: default/fixed use Cascadia Code, variable uses Segoe UI
(set-face-attribute 'default nil :family "Cascadia Code" :height 120)
(set-face-attribute 'fixed-pitch nil :family "Cascadia Code" :height 120)
(set-face-attribute 'variable-pitch nil :family "Segoe UI" :height 120)

(setq inhibit-startup-screen t
      initial-scratch-message "")

;; Indentation: spaces only, 4-wide
(setq-default indent-tabs-mode nil
              tab-width 4)

(defun my-c-hook ()
  (c-set-style "linux")
  (setq c-basic-offset 4)
  (setq-local evil-shift-width 4))

(add-hook 'c-mode-common-hook #'my-c-hook)

;; Backup / auto-save (cross-platform paths)
(setq backup-directory-alist
      `(("." . ,(expand-file-name "backups/" user-emacs-directory)))
      auto-save-file-name-transforms
      `((".*" ,(expand-file-name "auto-save/" user-emacs-directory) t))
      create-lockfiles nil)

(make-directory (expand-file-name "backups/"   user-emacs-directory) t)
(make-directory (expand-file-name "auto-save/" user-emacs-directory) t)

;;; ==========================================
;;; package management
;;; ==========================================
(require 'package)
(setq package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)
(setq use-package-always-ensure t)

;;; --- theme ---
(use-package vscode-dark-plus-theme
  :config
  (load-theme 'vscode-dark-plus t))

;;; ==========================================
;;; lsp / eglot
;;; ==========================================
(use-package eglot
  :ensure nil
  :hook ((c-mode . eglot-ensure)
         (c++-mode . eglot-ensure)))

;;; ==========================================
;;; evil mode
;;; ==========================================
(use-package evil
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-visual-char-semi-at-end-of-line t)
  :config
  (evil-mode 1)
  (setq evil-backspace-join-lines nil)
  (define-key evil-insert-state-map [backspace] #'backward-delete-char)
  (define-key evil-motion-state-map (kbd "j") #'evil-next-visual-line)
  (define-key evil-motion-state-map (kbd "k") #'evil-previous-visual-line))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;;; ==========================================
;;; evil org
;;; ==========================================
(use-package evil-org
  :after org
  :hook (org-mode . evil-org-mode)
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

;;; ==========================================
;;; yank & undo
;;; ==========================================
(setq select-enable-clipboard t
      select-enable-primary t
      save-interprogram-paste-before-kill t
      yank-pop-change-selection t)

(use-package undo-tree
  :config
  (global-undo-tree-mode 1)
  (setq undo-tree-auto-save-history nil)
  (evil-set-undo-system 'undo-tree))

;;; ==========================================
;;; org mode
;;; ==========================================
(use-package org
  :hook (org-mode . visual-line-mode)
  :custom
  (org-attach-use-inheritance t)
  (org-attach-auto-tag nil)
  (org-hide-emphasis-markers t)
  (org-hide-drawer-startup t)
  (org-return-follows-link t)
  (org-src-window-setup 'current-window)
  (org-src-preserve-indentation t)
  (org-startup-with-inline-images t)
  (org-src-fontify-natively t)
  (org-src-tab-acts-natively t)
  (org-startup-folded 'overview)
  (org-todo-keyword-faces
   '(("IN-PROGRESS" . (:foreground "#8eb0eb" :weight bold))
     ("WAITING"     . (:foreground "#ffdd33" :weight bold))))
  :config
  (require 'org-tempo)
  (setf (cdr (assoc 'file org-link-frame-setup)) #'find-file))

(use-package org-roam
  :custom
  (org-roam-directory (expand-file-name ".roam/" user-emacs-directory))
  (org-roam-file-exclude-regexp "\\.gpg$")
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture))
  :config
  (make-directory org-roam-directory t)
  (org-roam-db-autosync-mode))

(use-package org-appear
  :hook (org-mode . org-appear-mode)
  :custom
  (org-appear-autolinks t)
  (org-appear-autosubmarkers t)
  (org-appear-autokeywords t))

;;; ==========================================
;;; markdown-preview look for org-mode
;;; ==========================================
(use-package org-modern
  :hook (org-mode . org-modern-mode)
  :custom
  (org-modern-star '("●" "○" "◆" "◇" "■" "□" "▪" "·"))
  (org-modern-table nil)
  (org-modern-tag t)
  (org-modern-priority t)
  (org-modern-keyword t))

(use-package mixed-pitch
  :hook (org-mode . mixed-pitch-mode)
  :custom
  (mixed-pitch-set-height t))

(use-package valign
  :hook (org-mode . valign-mode)
  :custom
  (valign-fancy-bar nil))   ; was t — fancy bar redraws | with a colored face


;;; --- org faces ----------------------------------------------------------
(defun my/set-face-attrs (faces &rest attrs)
  "Apply ATTRS to each existing face in FACES."
  (dolist (face faces)
    (when (facep face)
      (apply #'set-face-attribute face nil attrs))))

(defun my/org-faces ()
  ;; Headlines
  (let ((palette '(("org-level-1" . "#569cd6")
                   ("org-level-2" . "#4ec9b0")
                   ("org-level-3" . "#d7d4a0")   ; was #dcdcaa — softened value
                   ("org-level-4" . "#c586c0")
                   ("org-level-5" . "#ce9178")
                   ("org-level-6" . "#a2cfe6")   ; was #9cdcfe — reduced chroma
                   ("org-level-7" . "#569cd6")
                   ("org-level-8" . "#4ec9b0"))))
    (dolist (entry palette)
      (set-face-attribute (intern (car entry)) nil
                          :foreground (cdr entry)
                          :weight 'bold
                          :height 1.0)))

  ;; Code blocks
  (set-face-attribute 'org-block nil
                      :background "#1a2030" :foreground "#d4d4d4" :extend t)
  (my/set-face-attrs '(org-block-begin-line org-block-end-line)
                     :background "#1f2940" :foreground "#569cd6"
                     :weight 'bold :extend t)
  (set-face-attribute 'org-code nil
                      :background "#1f2940" :foreground "#9cdcfe")

  ;; Tables — render as plain text (no bg, no fg tint on |, +, -)
  (my/set-face-attrs '(org-table org-table-header
                                 valign-table valign-table-fallback)
                     :foreground 'unspecified
                     :background 'unspecified
                     :inherit 'default)

  ;; org-modern labels
  (my/set-face-attrs '(org-modern-label org-modern-block-name)
                     :background "#2d3a5a" :foreground "#9cdcfe"
                     :weight 'bold :inherit 'unspecified))

(add-hook 'org-mode-hook #'my/org-faces)
(add-hook 'after-load-theme-hook #'my/org-faces)

;;; ==========================================
;;; encryption (epa)
;;; ==========================================
(epa-file-enable)
(setq epg-pinentry-mode 'loopback
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
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode))

;;; ==========================================
;;; leader key (general.el)
;;; ==========================================
(use-package general
  :config
  (general-auto-unbind-keys)
  (general-create-definer my-leader-def
    :states '(normal visual motion emacs)
    :keymaps 'override
    :prefix "SPC"
    :non-normal-prefix "M-SPC")

  (my-leader-def
    "b"  #'consult-buffer
    "f"  #'consult-find
    "s"  #'consult-line
    "g"  #'consult-grep
    "i"  #'ibuffer
    "a"  #'org-agenda
    "tc" #'org-capture
    "nf" #'org-roam-node-find
    "ni" #'org-roam-node-insert
    "nc" #'org-roam-capture
    "p"  #'consult-yank-pop
    "u"  #'undo-tree-visualize
    "mg" #'magit-status
    "cr" #'eglot-rename
    "cu" #'xref-find-references
    "ca" #'eglot-code-actions)

  (with-eval-after-load 'org
    (general-define-key
     :keymaps 'org-mode-map
     :states '(normal motion)
     (kbd "RET") #'org-open-at-point)))
