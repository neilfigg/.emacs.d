
(setq user-full-name "Neil Figg")
(setq user-mail-address "neil.figg@gmail.com")

(require 'package)

(defvar gnu '("gnu" . "https://elpa.gnu.org/packages/"))
(defvar melpa '("melpa" . "https://melpa.org/packages/"))
(defvar melpa-stable '("melpa-stable" . "https://stable.melpa.org/packages/"))
(defvar org-elpa '("org" . "http://orgmode.org/elpa/"))

;; Add marmalade to package repos
(setq package-archives nil)
(add-to-list 'package-archives melpa-stable t)
(add-to-list 'package-archives melpa t)
(add-to-list 'package-archives gnu t)
(add-to-list 'package-archives org-elpa t)

;;(setq init-dir (file-name-directory (or load-file-name (buffer-file-name))))

(package-initialize)

(unless (and (file-exists-p (concat user-emacs-directory "elpa/archives/gnu"))
             (file-exists-p (concat user-emacs-directory "elpa/archives/melpa"))
             (file-exists-p (concat user-emacs-directory "elpa/archives/melpa-stable")))
  (package-refresh-contents))

(defun packages-install (&rest packages)
  (message "running packages-install")
  (mapc (lambda (package)
          (let ((name (car package))
                (repo (cdr package)))
            (when (not (package-installed-p name))
              (let ((package-archives (list repo)))
                (package-initialize)
                (package-install name)))))
        packages)
  (package-initialize)
  (delete-other-windows))

;; Install extensions if they're missing
(defun init--install-packages ()
  (message "Installing packages")
  (packages-install
   ;; Since use-package this is the only entry here
   ;; ALWAYS try to use use-package!
   (cons 'use-package melpa)
   ))

(condition-case nil
    (init--install-packages)
  (error
   (package-refresh-contents)
   (init--install-packages)))

(use-package cider
  :ensure t
  :config
 ;; (diminish-major 'cider-repl-mode nil)
 ;; (diminish-major 'cider-stacktrace-mode nil)
 ;; (diminish-major 'nrepl-messages-mode nil)

  (setq cider-auto-select-error-buffer t
        cider-macroexpansion-print-metadata t
        cider-mode-line nil
        cider-pprint-fn 'puget
        cider-prompt-for-symbol nil
        cider-repl-display-help-banner nil
        cider-repl-history-file (concat user-emacs-directory ".cider-history")
        cider-repl-history-size 1000
        cider-repl-pop-to-buffer-on-connect nil
        cider-repl-use-clojure-font-lock t
        cider-repl-use-pretty-printing t
        cider-repl-wrap-history t
        cider-show-error-buffer 'always
        nrepl-buffer-name-show-port t
        nrepl-log-messages t
        nrepl-message-buffer-max-size 100000000)

  ;; TODO https://github.com/bbatsov/solarized-emacs/issues/231
  (set-face-attribute 'cider-deprecated-face nil :background nil :underline "light goldenrod")

  (add-hook 'cider-inspector-mode-hook 'hide-trailing-whitespace)
  (add-hook 'cider-mode-hook 'enable-eldoc-mode)
  (add-hook 'cider-repl-mode-hook 'enable-eldoc-mode)
  (add-hook 'cider-repl-mode-hook 'enable-clj-refactor-mode)
  (add-hook 'cider-repl-mode-hook 'enable-paredit-mode)
  (add-hook 'cider-repl-mode-hook 'hide-trailing-whitespace)
)

(use-package clojure-mode
  :ensure t
  :config
  ;;(diminish-major 'clojure-mode "clj")
  (add-hook 'clojure-mode-hook 'enable-clj-refactor-mode)
  (add-hook 'clojure-mode-hook 'enable-paredit-mode)
  (add-hook 'clojure-mode-hook 'rainbow-delimiters-mode)
  (add-hook 'clojure-mode-hook 'aggressive-indent-mode)
)

(use-package clj-refactor
  :ensure t
  :commands
  enable-clj-refactor-mode
  :config
  (setq cljr-eagerly-build-asts-on-startup nil
        cljr-eagerly-cache-macro-occurrences-on-startup nil
        cljr-favor-prefix-notation nil
        cljr-magic-requires nil)
  (defun enable-clj-refactor-mode ()
    (interactive)
    (clj-refactor-mode 1)
    (diminish 'clj-refactor-mode)
(cljr-add-keybindings-with-prefix "C-c r")))

(use-package aggressive-indent
    :ensure t
    :config
(add-hook 'clojure-mode-hook 'aggressive-indent-mode))

(use-package eldoc
  :commands
  enable-eldoc-mode
  :config
  (diminish 'eldoc-mode)
  (setq eldoc-idle-delay 0)

  (defun enable-eldoc-mode ()
    (interactive)
    (eldoc-mode 1)))

(use-package projectile
  :config
  (projectile-global-mode 1)
  (diminish 'projectile-mode)
  (setq projectile-cache-file (concat user-emacs-directory "projectile/cache")
        projectile-known-projects-file (concat user-emacs-directory "projectile/bookmarks.eld")
        projectile-use-git-grep t
        projectile-switch-project-action 'projectile-dired))

(use-package s
  :ensure t)

(use-package hydra
  :ensure t)

(use-package hideshow
  :ensure t
  :bind (("C->" . my-toggle-hideshow-all)
         ("C-<" . hs-hide-level)
         ("C-;" . hs-toggle-hiding))
  :config
  ;; Hide the comments too when you do a 'hs-hide-all'
  (setq hs-hide-comments nil)
  ;; Set whether isearch opens folded comments, code, or both
  ;; where x is code, comments, t (both), or nil (neither)
  (setq hs-isearch-open 'x)
  ;; Add more here


  (setq hs-set-up-overlay
        (defun my-display-code-line-counts (ov)
          (when (eq 'code (overlay-get ov 'hs))
            (overlay-put ov 'display
                         (propertize
                          (format " ... <%d>"
                                  (count-lines (overlay-start ov)
                                               (overlay-end ov)))
                          'face 'font-lock-type-face)))))

  (defvar my-hs-hide nil "Current state of hideshow for toggling all.")
       ;;;###autoload
  (defun my-toggle-hideshow-all () "Toggle hideshow all."
         (interactive)
         (setq my-hs-hide (not my-hs-hide))
         (if my-hs-hide
             (hs-hide-all)
           (hs-show-all)))

  (add-hook 'prog-mode-hook (lambda ()
                              (hs-minor-mode 1)
                              ))
  (add-hook 'clojure-mode-hook (lambda ()
                              (hs-minor-mode 1)
                              ))
  )

(use-package paredit
  :ensure t
 ;; :diminish paredit-mode
  :config
  (add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
  (add-hook 'ielm-mode-hook             #'enable-paredit-mode)
  (add-hook 'lisp-mode-hook             #'enable-paredit-mode)
  (add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
  (add-hook 'scheme-mode-hook           #'enable-paredit-mode)
  :bind (("C-c d" . paredit-forward-down))
  )

;; Ensure paredit is used EVERYWHERE!
(use-package paredit-everywhere
  :ensure t
  :diminish paredit-everywhere-mode
  :config
  (add-hook 'prog-mode-hook #'paredit-everywhere-mode))

(use-package highlight-parentheses
  :ensure t
  :diminish highlight-parentheses-mode
  :config
  (add-hook 'emacs-lisp-mode-hook
            (lambda()
              (highlight-parentheses-mode)
              )))

(use-package rainbow-delimiters
  :ensure t
  :config
  (add-hook 'lisp-mode-hook
            (lambda()
              (rainbow-delimiters-mode)
              )))

(global-highlight-parentheses-mode)

(use-package company
  :config
  (global-company-mode 1)
  (diminish 'company-mode)
  (setq company-idle-delay nil
        company-minimum-prefix-length 0
        company-selection-wrap-around t
        company-tooltip-align-annotations t
        company-tooltip-limit 16
        company-require-match nil)
  (bind-key "C-q" #'company-show-doc-buffer company-active-map)
  :bind
(("C-<tab>" . company-complete)))

(use-package magit
  :config
  (global-set-key (kbd "C-c m") 'magit-status))

(defun iwb ()
  "indent whole buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))

(global-set-key (kbd "C-c n") 'iwb)

(electric-pair-mode t)

(use-package restclient
  :ensure t)

(use-package project-shells
   :ensure t
   :config
 (global-project-shells-mode)
 (setf project-shells-setup
`(("redplan" .
   (("0" .
     ("build" "~/data/projects/redplan"))
    ("9" .
     ("files" "~/data/data/files"))
    ("8" .
     ("redplan" "~/data/projects/redplan")))))))

(use-package dash
  :ensure t)

(use-package bm
    :ensure t
    :bind (("C-c =" . bm-toggle)
           ("C-c [" . bm-previous)
           ("C-c ]" . bm-next)))

(use-package counsel
  :ensure t
  :bind
  (("M-x" . counsel-M-x)
   ("M-y" . counsel-yank-pop)
   :map ivy-minibuffer-map
   ("M-y" . ivy-next-line)))

 (use-package swiper
   :pin melpa-stable
   :diminish ivy-mode
   :ensure t
   :bind*
   (("C-s" . swiper)
    ("C-c C-r" . ivy-resume)
    ("C-x C-f" . counsel-find-file)
    ("C-c h f" . counsel-describe-function)
    ("C-c h v" . counsel-describe-variable)
    ("C-c i u" . counsel-unicode-char)
    ("M-i" . counsel-imenu)
    ("C-c g" . counsel-git)
    ("C-c j" . counsel-git-grep)
    ("C-c k" . counsel-ag)
    ("C-c l" . scounsel-locate))
   :config
   (progn
     (ivy-mode 1)
     (setq ivy-use-virtual-buffers t)
     (setq ivy-display-style 'fancy)
     (define-key read-expression-map (kbd "C-r") #'counsel-expression-history)
     (ivy-set-actions
      'counsel-find-file
      '(("d" (lambda (x) (delete-file (expand-file-name x)))
         "delete"
         )))
     (ivy-set-actions
      'ivy-switch-buffer
      '(("k"
         (lambda (x)
           (kill-buffer x)
           (ivy--reset-state ivy-last))
         "kill")
        ("j"
         ivy--switch-buffer-other-window-action
         "other window")))))

(use-package counsel-projectile
  :ensure t
  :config
  (counsel-projectile-on))

(use-package ivy-hydra :ensure t)

(use-package which-key
  :ensure t
  :diminish which-key-mode
  :config
  (which-key-mode))

(use-package ace-window
  :ensure t
  :config
  (global-set-key (kbd "C-x o") 'ace-window))

(use-package ace-jump-mode
  :ensure t
  :config
  (define-key global-map (kbd "C-c SPC") 'ace-jump-mode))

(fset 'yes-or-no-p 'y-or-n-p)

(global-hl-line-mode +1)

(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region))

(global-set-key (kbd "C-x k") 'kill-this-buffer)

(defun nuke-all-buffers ()
  (interactive)
  (mapcar 'kill-buffer (buffer-list))
  (delete-other-windows))

(blink-cursor-mode -1)
(menu-bar-mode 1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)

(setq delete-by-moving-to-trash t
         trash-directory "~/.Trash/emacs")

(setq ns-pop-up-frames nil)

(setq inhibit-startup-message t)

(global-linum-mode)

(line-number-mode t)
(column-number-mode t)
(size-indication-mode t)

(use-package command-log-mode
  :ensure t)

(defun live-coding ()
  (interactive)
  (set-face-attribute 'default nil :font "Hack-20")
  (add-hook 'prog-mode-hook 'command-log-mode)
  ;;(add-hook 'prog-mode-hook (lambda () (focus-mode 1)))
  )

(delete-selection-mode t)

(setq require-final-newline t)

(eval-after-load "org-indent" '(diminish 'org-indent-mode))

(defun my-bell-function ())

(setq ring-bell-function 'my-bell-function)
(setq visible-bell nil)

(dolist (hook '(text-mode-hook))
  (add-hook hook (lambda ()
                   (flyspell-mode 1)
                   (visual-line-mode 1)
                   )))

(global-prettify-symbols-mode 1)

(setq x-select-enable-clipboard t)

(global-auto-revert-mode 1)

(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)

(setq fill-column 80)
(set-default 'fill-column 80)

(set-default 'indent-tabs-mode nil)

(set-default 'indicate-empty-lines t)

(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(add-to-list 'load-path "~/.emacs.d/themes")

(load-theme 'solarized-dark t)

(use-package markdown-mode
  :ensure t)

(use-package htmlize
  :ensure t)

(setq backup-directory-alist `(("." . "~/.emacs.d/backups")))
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save" t)))
(setq delete-by-moving-to-trash t trash-directory "~/.Trash/emacs")

;; https://www.emacswiki.org/emacs/BackupFiles
(setq
 backup-by-copying t     ; don't clobber symlinks
 kept-new-versions 10    ; keep 10 latest versions
 kept-old-versions 0     ; don't bother with old versions
 delete-old-versions t   ; don't ask about deleting old versions
 version-control t       ; number backups
 vc-make-backup-files t  ; backup version controlled files
)

(setq savehist-file "~/.emacs.d/.savehist")
(savehist-mode 1)
(setq history-length t)
(setq history-delete-duplicates t)
(setq savehist-save-minibuffer-history 1)
(setq savehist-additional-variables
      '(kill-ring
        search-ring
        regexp-search-ring))

(set-charset-priority 'unicode)
(set-coding-system-priority 'utf-8)
(set-language-environment "UTF-8")

(setq locale-coding-system 'utf-8)

(set-clipboard-coding-system 'utf-8)
(set-file-name-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)

(prefer-coding-system 'utf-8)