
(setq user-full-name "Neil Figg")
(setq user-mail-address "neil.figg@gmail.com")

(require 'package)
(setq package-enable-at-startup nil)   ; To prevent initialising twice
(setq package-archives nil)

(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)

(package-initialize)

(unless (and (file-exists-p (concat user-emacs-directory "elpa/archives/org"))
             (file-exists-p (concat user-emacs-directory "elpa/archives/gnu"))
             (file-exists-p (concat user-emacs-directory "elpa/archives/melpa"))
             (file-exists-p (concat user-emacs-directory "elpa/archives/melpa-stable"))))

(unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(use-package no-littering
  :ensure t
  :config
  (require 'recentf)
  (add-to-list 'recentf-exclude no-littering-var-directory)
  (add-to-list 'recentf-exclude no-littering-etc-directory))

(use-package clojure-mode
  :ensure t
  :pin melpa-stable
  :init
  (add-hook 'clojure-mode-hook #'eldoc-mode)
  (add-hook 'clojure-mode-hook #'paredit-mode)
  (add-hook 'clojure-mode-hook #'rainbow-delimeters-mode)
  (add-hook 'clojure-mode-hook #'aggressive-indent-mode)
  (add-hook 'clojure-mode-hook #'subword-mode)
  (add-hook 'clojure-mode-hook #'cider-mode)
  (add-hook 'clojure-mode-hook #'clj-refactor-mode)
  :config
  (outline-minor-mode 1))

(use-package cider
 :ensure t
 :pin melpa-stable
 :init
 (add-hook 'cider-mode-hook #'clj-refactor-mode)
 (add-hook 'cider-mode-hook #'company-mode)
 (add-hook 'cider-repl-mode-hook #'company-mode)
 :diminish subword-mode
 :config
 (setq cider-auto-select-error-buffer t
       cider-macroexpansion-print-metadata t
       cider-mode-line nil
       cider-overlays-use-font-lock t
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
       nrepl-message-buffer-max-size 100000000
       cider-test-show-report-on-success t))

(use-package clj-refactor
  :ensure t
  :pin melpa-stable
  :commands
  enable-clj-refactor-mode
  :config
  (add-hook 'clojure-mode-hook    #'enable-clj-refactor-mode)
  (add-hook 'cider-repl-mode-hook #'enable-clj-refactor-mode)
  (setq cljr-eagerly-build-asts-on-startup nil
        cljr-eagerly-cache-macro-occurrences-on-startup nil
        cljr-favor-prefix-notation nil
        cljr-magic-requires :prompt)
  (defun enable-clj-refactor-mode ()
    (interactive)
    (clj-refactor-mode 1)
    (yas-minor-mode 1) ; for adding require/use/import statements
    (diminish 'clj-refactor-mode)
    (cljr-add-keybindings-with-prefix "C-c C-m")))

(use-package clojure-snippets
    :ensure t)

(use-package company
:ensure t
:config
(diminish 'company-mode)
(add-hook 'clojure-mode-hook    #'company-mode)
(add-hook 'cider-repl-mode-hook #'company-mode)
(add-hook 'cider-mode-hook #'company-mode)
(add-hook 'cider-repl-mode-hook #'cider-company-enable-fuzzy-completion)
(add-hook 'cider-mode-hook #'cider-company-enable-fuzzy-completion)
;;(setq 
     ;; company-idle-delay nil ; never start completions automatically
     ;; company-minimum-prefix-length 0
     ;; company-selection-wrap-around t
     ;; company-tooltip-align-annotations t
     ;; company-tooltip-limit 16
     ;; company-require-match nil)
(global-set-key (kbd "TAB") #'company-indent-or-complete-common))

(use-package projectile
  :ensure t
  :config
  (projectile-global-mode 1)
  (diminish 'projectile-mode)
  (setq projectile-cache-file (concat user-emacs-directory "projectile/cache")
        projectile-known-projects-file (concat user-emacs-directory "projectile/bookmarks.eld")
        projectile-use-git-grep t
        projectile-switch-project-action 'projectile-dired))

(use-package neotree
  :ensure t
  :init
  (setq neo-smart-open t
        projectile-switch-project-action #'neotree-projectile-action)
  :config
  (global-set-key [f8] 'neotree-toggle))

(use-package aggressive-indent
  :ensure t
  :config
  (add-hook 'clojure-mode-hook #'aggressive-indent-mode))

(use-package eldoc
  :commands
  enable-eldoc-mode
  :config
  (add-hook 'cider-mode-hook #'enable-eldoc-mode)
  (add-hook 'cider-repl-mode-hook #'enable-eldoc-mode)
  (diminish 'eldoc-mode)
  (setq eldoc-idle-delay 0)
  (defun enable-eldoc-mode ()
      (interactive)
      (eldoc-mode 1)))

(use-package s
 :ensure t)

(use-package hydra
  :ensure t)

(use-package paredit
  :ensure t
  :diminish paredit-mode
  :config
  (add-hook 'clojure-mode-hook          #'enable-paredit-mode)
  (add-hook 'cider-repl-mode-hook       #'enable-paredit-mode)
  (add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
  (add-hook 'ielm-mode-hook             #'enable-paredit-mode)
  (add-hook 'lisp-mode-hook             #'enable-paredit-mode)
  (add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
  (add-hook 'scheme-mode-hook           #'enable-paredit-mode)
  :bind (("C-c d" . paredit-forward-down)))

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
              (highlight-parentheses-mode))))

(use-package rainbow-delimiters
  :ensure t
  :config
  (add-hook 'clojure-mode-hook    #'rainbow-delimiters-mode)
  (add-hook 'cider-repl-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'lisp-mode-hook
            (lambda()
              (rainbow-delimiters-mode)
              ))
  (global-highlight-parentheses-mode))

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

(setq mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control) . nil))
      mouse-wheel-progressive-speed nil)

(setq delete-by-moving-to-trash t
      trash-directory "~/.Trash/emacs")

(setq ns-pop-up-frames nil)

(setq inhibit-startup-message t)

(global-linum-mode)

(line-number-mode t)
(column-number-mode t)
(size-indication-mode t)

(delete-selection-mode t)

(setq require-final-newline t)

(eval-after-load "org-indent" '(diminish 'org-indent-mode))

(defun my-bell-function ())
(setq ring-bell-function 'my-bell-function
      visible-bell nil)

(dolist (hook '(text-mode-hook))
  (add-hook hook (lambda ()
                   (flyspell-mode 1)
                   (visual-line-mode 1)
                   )))

(global-prettify-symbols-mode 1)

(setq x-select-enable-clipboard t)

(global-auto-revert-mode 1)

(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)

(setq fill-column 80)
(set-default 'fill-column 80)

(set-default 'indent-tabs-mode nil)

(set-default 'indicate-empty-lines t)

(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

(use-package magit                    
  :ensure t
  :bind (("C-c v c" . magit-clone)
         ("C-c v v" . magit-status)
         ("C-c v g" . magit-blame)
         ("C-c v l" . magit-log-buffer-file)
         ("C-c v p" . magit-pull))
   :config (setq magit-save-repository-buffers 'dontask))

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(add-to-list 'load-path "~/.emacs.d/themes")

(use-package rainbow-mode                   
  :ensure t)

(defvar zenburn-override-colors-alist
  '(("zenburn-bg+05" . "#282828")
    ("zenburn-bg+1"  . "#2F2F2F")
    ("zenburn-bg+2"  . "#3F3F3F")
    ("zenburn-bg+3"  . "#4F4F4F")))
(load-theme 'zenburn t)

(use-package markdown-mode
  :ensure t)

(use-package htmlize
  :ensure t)

(setq backup-directory-alist `(("." . "~/.emacs.d/backups"))
      auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save" t))
      auto-save-list-file-prefix "~/.emacs.d/auto-save"
      delete-by-moving-to-trash t trash-directory "~/.Trash/emacs")

;; https://www.emacswiki.org/emacs/BackupFiles
(setq  backup-by-copying t     ; don't clobber symlinks
       kept-new-versions 10    ; keep 10 latest versions
       kept-old-versions 0     ; don't bother with old versions
       delete-old-versions t   ; don't ask about deleting old versions
       version-control t       ; number backups
       ;;vc-make-backup-files t  ; backup version controlled files
)

(setq savehist-file "~/.emacs.d/.savehist"
      history-length t
      history-delete-duplicates t
      savehist-save-minibuffer-history 1
      savehist-additional-variables
      '(kill-ring
        search-ring
        regexp-search-ring))

 (savehist-mode 1)

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
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (htmlize markdown-mode rainbow-mode magit expand-region ace-jump-mode ace-window which-key ivy-hydra counsel-projectile counsel bm dash rainbow-delimiters highlight-parentheses paredit-everywhere aggressive-indent neotree projectile company clojure-snippets use-package no-littering clj-refactor))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
