;;; ==========================================
;;; CORE UI & BEHAVIOR
;;; ==========================================
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode 1)

(setq display-line-numbers-type 'visual)
(global-display-line-numbers-mode 1)
(global-auto-revert-mode t)            ;; Reload buffer when file changed
(setq inhibit-startup-screen t)        ;; No splash screen
(setq initial-scratch-message "")      ;; Clean, empty scratch buffer
(setq initial-major-mode 'lisp-interaction-mode) 

;;; --- TABS & INDENTATION ---
(setq-default indent-tabs-mode t)      ;; Use tabs instead of spaces
(setq-default tab-always-indent nil)   ;; Tab key inserts real tab when appropriate
(setq-default tab-width 4)             ;; Visual width of a tab
(setq-default standard-indent 4)       ;; Indentation step
(setq-default backward-delete-char-untabify nil) ;; Don't turn tabs into spaces on delete

;;; --- C/C++ MODE (Matching Vim's cindent) ---
(defun my-c-mode-hook ()
  ;; Use a base style that closely mimics standard Vim cindent
  ;;(c-set-style "bsd")
  (c-set-style "linux")
  
  ;; Force C-mode to use hard tabs (cc-mode can sometimes override global settings)
  (setq indent-tabs-mode t)
  
  ;; Vim: set shiftwidth=4
  (setq c-basic-offset 4)
  
  ;; Vim: set tabstop=4 (Ensure C-mode specifically uses visual width of 4)
  (setq tab-width 4)
  
  ;; Match Evil's indentation operator (>> and <<) to the C offset
  (setq-local evil-shift-width 4)
  
  ;; Prevent Tab from ONLY indenting; allow it to insert a tab character like Vim's insert mode
  (setq c-tab-always-indent nil))

(add-hook 'c-mode-hook 'my-c-mode-hook)
(add-hook 'c++-mode-hook 'my-c-mode-hook)

;;; --- AUTO SAVE & BACKUP ---
(setq backup-directory-alist '(("." . "~/.emacs.d/backups/")))
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save/" t)))
(setq create-lockfiles nil) ;; Disable lock files (.#filename)

;; Create the directories automatically if they don't exist
(make-directory "~/.emacs.d/backups/" t)
(make-directory "~/.emacs.d/auto-save/" t)

;;; ==========================================
;;; PACKAGE MANAGEMENT
;;; ==========================================
(require 'package)
(setq package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

;;; --- THEME ---
(setq custom-file "~/.emacs.d/emacs.custom")
(load custom-file 'noerror)

(use-package gruber-darker-theme
  :ensure t
  :config
  (load-theme 'gruber-darker t))

;;; ==========================================
;;; EVIL MODE (VIM EMULATION)
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
  
  ;; Fix Backspace in insert mode
  (define-key evil-insert-state-map [backspace] 'backward-delete-char)
  
  ;; Global Visual Line Navigation (Moved out of Org-mode scope)
  (define-key evil-motion-state-map (kbd "j") 'evil-next-visual-line)
  (define-key evil-motion-state-map (kbd "k") 'evil-previous-visual-line))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

;;; ==========================================
;;; LEADER KEY (GENERAL.EL)
;;; ==========================================
(use-package general
  :ensure t
  :config
  (general-create-definer my-leader-def
    :states '(normal visual motion emacs)
    :keymaps 'override ;; Ensures SPC works even in Dired/Magit overriding default modes
    :prefix "SPC"
    :non-normal-prefix "M-SPC")

  ;; Single Source of Truth for core actions (removed M-s overlapping logic)
  (my-leader-def
    "b" 'consult-buffer
    "f" 'consult-find
    "s" 'consult-line
    "g" 'consult-grep
    "i" 'ibuffer))

;;; ==========================================
;;; UTILITIES & TOOLS
;;; ==========================================
;; Global fallback for ibuffer (optional, since SPC i does this too)
(global-set-key (kbd "C-x C-b") 'ibuffer) 

;; Compilation Colors
(require 'ansi-color)
(defun my-colorize-compilation-buffer ()
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region compilation-filter-start (point-max))))
(add-hook 'compilation-filter-hook 'my-colorize-compilation-buffer)

;;; --- ORG MODE ---
(use-package org
  :hook (org-mode . visual-line-mode)
  :config
  (setq org-return-follows-link t)
  (setf (cdr (assoc 'file org-link-frame-setup)) 'find-file)
  
  ;; Force Evil to use Org's return logic
  (evil-define-key 'motion org-mode-map (kbd "RET") 'org-return)
  (evil-define-key 'normal org-mode-map (kbd "RET") 'org-return))

(use-package org-modern
  :ensure t
  :hook (org-mode . org-modern-mode)
  :config
  (setq
   ;; Edit these to your liking
   org-modern-star '("◉" "○" "◈" "◇" "⁖")
   org-modern-table nil   ; Set to t if you want fancy tables
   org-modern-tag t
   org-modern-priority t
   org-modern-keyword t))

(custom-set-faces
 ;; 1. Large Source Blocks
 '(org-block ((t (:background "#1e1e1e" :extend t :inherit fixed-pitch))))
 '(org-block-begin-line ((t (:background "#252525" :foreground "#51afef" :extend t :inherit fixed-pitch))))
 '(org-block-end-line ((t (:background "#252525" :foreground "#51afef" :extend t :inherit fixed-pitch))))
 
 ;; 2. Inline Code (=code=) - Added a :box for a "button" effect
 '(org-code ((t (:background "#2e2e2e" 
                 :foreground "#ce9178" 
                 :box (:line-width 1 :color "#3e3e3e") 
                 :inherit fixed-pitch))))
 
 ;; 3. Verbatim (~verbatim~)
 '(org-verbatim ((t (:background "#2e2e2e" 
                     :foreground "#b5cea8" 
                     :box (:line-width 1 :color "#3e3e3e") 
                     :inherit fixed-pitch)))))

(setq org-src-window-setup 'current-window) ;; Edit code in the same window

;;; ==========================================
;;; COMPLETION FRAMEWORK
;;; ==========================================
(use-package consult
  :ensure t
  ;; Bindings cleared: Rely on your General 'SPC' bindings to prevent overlap
  )

(use-package vertico
  :ensure t
  :init
  (vertico-mode 1)
  :bind (:map vertico-map
              ("C-j" . vertico-next)
              ("C-k" . vertico-previous)
              ("C-l" . vertico-exit)) ;; Note: usually RET is exit, but leaving C-l per your preference
  :config
  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook 'cursor-intangible-mode))

;; ;;; --- ORDERLESS (Better Filtering) ---
;; (use-package orderless
;;   :ensure t
;;   :custom
;;   (completion-styles '(orderless basic))
;;   (completion-category-overrides '((file (styles basic partial-completion)))))

