
;; Increase the buffer size of *Messages*
(setq message-log-max 20000)

;; Increase the garbage collection threshold during startup
(defconst pvj/default-gc-cons-threshold gc-cons-threshold)
(setq gc-cons-threshold (* 256 1024 1024))
(add-hook 'after-init-hook
          (lambda () (setq gc-cons-threshold pvj/default-gc-cons-threshold)))

(setq package-archives '(
                         ("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")))
(package-initialize)

;;
;; Use 'use-package'
;;
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(use-package use-package
  :config
  (setq use-package-always-ensure t)
  (setq use-package-always-pin "melpa"))

(add-to-list 'load-path (expand-file-name "elisp" user-emacs-directory))

;; Set the custom file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

;; Get rid of the splash screen and echo area message
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message t)

;;
;; Use persistent scratch buffer
;;
(use-package persistent-scratch
  :config
  (setq initial-scratch-message "")
  (persistent-scratch-setup-default))

;;
;; Remember recently opened files
;;
(setq recentf-exclude '("/Maildir/" ".aspell."))
(setq recentf-max-saved-items 50)

;;
;; dired+ configuration
;;
(use-package dired+
  :config
  (setq diredp-hide-details-initially-flag nil)
  (setq diredp-hide-details-propagate-flag nil)
  (setq dired-listing-switches "-alh"))

;;
;; Tree-based file explorer
;;
(use-package neotree
  :bind (([f7] . neotree-toggle))
  :config
  (setq neo-theme 'classic)
  (setq neo-smart-open t)
  (setq neo-window-fixed-size nil)
  (setq neo-window-width 50)
  (setq neo-fit-to-contents t)
  (setq neo-vc-integration (quote (face)))
  (setq neo-cwd-line-style 'text)
  (setq projectile-switch-project-action 'neotree-projectile-action))

;;
;; Configure helm mode
;;
(use-package helm
  :bind
  (("M-x" . helm-M-x)
   ("C-x r b" . helm-filtered-bookmarks)
   ("C-x C-f" . helm-find-files)
   ("C-x C-r" . helm-recentf)
   ("C-c m" . helm-mu-contacts)
   ;; Mark buffers with C-SPACE and kill them with M-D
   ("C-x C-b" . helm-buffers-list))
  :config
  (helm-mode 1)
  (setq helm-M-x-fuzzy-match t)
  (setq helm-buffers-fuzzy-matching t
        helm-recentf-fuzzy-match t)
  (setq helm-ff-newfile-prompt-p nil)
  ;; I used to have a problem where C-x C-f, i.e. helm-find-files would make emacs hang.
  ;; Workaround: by setting this flag I can prevent Emacs from hanging...
  (setq helm-split-window-in-side-p t))

(global-set-key (kbd "C-x k") 'kill-this-buffer)

;;
;; Helm interface for Emacs 'describe-bindings
;;
(use-package helm-descbinds
  :config
  (helm-descbinds-mode))

;; helm interface for projectile
(use-package helm-projectile
  :config
  (projectile-mode)
  (setq projectile-completion-system 'helm)
  (helm-projectile-on))

;; helm swoop
(use-package helm-swoop
  :bind
  (("M-i"     . helm-swoop)
   ("M-I"     . helm-swoop-back-to-last-point)
   ("C-c M-i" . helm-multi-swoop)
   ("C-x M-i" . helm-multi-swoop-all))
  :config
  ;; When doing isearch, hand the word over to helm-swoop
  (bind-key "M-i" #'helm-swoop-from-isearch isearch-mode-map)
  ;; From helm-swoop to helm-multi-swoop-all
  (bind-key "M-i" #'helm-multi-swoop-all-from-helm-swoop
            helm-swoop-map)
  ;; Move up and down like isearch
  (bind-keys :map helm-swoop-map
             ("C-r" . helm-previous-line)
             ("C-s" . helm-next-line))

  (bind-keys :map helm-multi-swoop-map
             ("C-r" . helm-previous-line)
             ("C-s" . helm-next-line))
  ;; Save buffer when helm-multi-swoop-edit complete
  (setq helm-multi-swoop-edit-save t)
  ;; If this value is t, split window inside the current window
  (setq helm-swoop-split-with-multiple-windows nil)
  ;; Split direcion. 'split-window-vertically or 'split-window-horizontally
  (setq helm-swoop-split-direction 'split-window-vertically)
  ;; If nil, you can slightly boost invoke speed in exchange for text color
  ;; (setq helm-swoop-speed-or-color nil)
  ;; ;; Go to the opposite side of line from the end or beginning of line
  (setq helm-swoop-move-to-line-cycle t)
  ;; Optional face for line numbers
  ;; Face name is `helm-swoop-line-number-face`
  (setq helm-swoop-use-line-number-face t)
  ;; If you prefer fuzzy matching
  (setq helm-swoop-use-fuzzy-match t))

;;
;; Enable winner-mode
;;
(winner-mode 1)

;;
;; Enable undo-tree
;;
(use-package undo-tree :config (global-undo-tree-mode))

;;
;; Show line numbers
;;
(global-linum-mode t)

;;
;; Setup LateX
;;
(require 'latex-config-pvj)

;;
;; For viewing PDF files
;;
(use-package pdf-tools
  :if (and (string-equal system-type "gnu/linux") (null noninteractive))
  :config 
  (pdf-tools-install))

;;
;; Disable line numbers in doc-view-mode (avoid Emacs hanging)
;;
(add-hook 'doc-view-mode-hook
  (lambda ()
    (linum-mode -1)))

;;
;; Functionality that supports text editing
;;
(require 'text-config-pvj)
(global-set-key (kbd "<f8>")   'pvj/switch-language)
(global-set-key (kbd "C-q") 'pvj/duplicate-current-line-or-region)
(global-set-key (kbd "C-d") 'kill-whole-line)
(delete-selection-mode 1)
(global-set-key (kbd "C-w") 'pvj/kill-word-or-region)
(global-set-key (kbd "<f6>") 'helm-show-kill-ring)
(global-set-key (kbd "C-c ;") 'comment-or-uncomment-region)
(global-set-key (kbd "<f1>")   'pvj/show-agenda)

;;
;; org-mode configuration
;;
(require 'org-pvj)

;;
;; Display current match and total matches in the mode-line in various search modes
;;
(use-package anzu
  :config
  (global-anzu-mode +1)
  (define-key isearch-mode-map [remap isearch-query-replace]  #'anzu-isearch-query-replace)
  (define-key isearch-mode-map [remap isearch-query-replace-regexp] #'anzu-isearch-query-replace-regexp))

;;
;; For language analysis
;;
(use-package langtool
  :config
  (setq langtool-language-tool-jar "~/tools/LanguageTool-3.4/languagetool-commandline.jar"))

;;
;; Enable word wrapping
;;
(global-visual-line-mode 1)

;;
;; Put backup files in same directory (to avoid having emacs creating files everywhere)
;;
(setq backup-directory-alist `(("." . ,(expand-file-name ".emacs-backup" user-emacs-directory))))

;;
;;  Show matching parentheses
;;
(show-paren-mode 1)
(setq show-paren-delay 0)

;;
;; Highlights delimiters such as parentheses, brackets or braces according to their depth
;;
(use-package rainbow-delimiters
  :config
  ;; To start the mode automatically in most programming modes (Emacs 24 and above):
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

;;
;; No blinking cursor
;;
(blink-cursor-mode 0)

;; Use the naquadah theme. In addition, the cursor color has been
;; changed to green, and the text-selection color (the region face)
;; has been changed to blue
(use-package naquadah-theme
  :demand
  :config
  (load-theme 'naquadah t))

;; Display the current column
(setq column-number-mode t)

;;
;; Show file name of current buffer
;;
;; (setq frame-title-format
;;      (list (format "%s %%S: %%j " (system-name))
;;        '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))

(put 'upcase-region 'disabled nil)

;;
;; Convenient way to tell emacs 'yes' or 'no'
;;
(defalias 'yes-or-no-p 'y-or-n-p)

;; If a file or buffer does not exist when using C-x C-f or C-x b then
;; skip the confirmation
(setq confirm-nonexistent-file-or-buffer nil)

;; Kill buffers that have a live process attached - without asking!
(setq kill-buffer-query-functions
  (remq 'process-kill-buffer-query-function
         kill-buffer-query-functions))

;; Move text
(use-package move-text
  :config
  (move-text-default-bindings))

;;
;; Disable auto-copy to clipboard for mouse
;;
(setq mouse-drag-copy-region nil)

;;
;; To avoid typing ESC-ESC-ESC to escape or quit
;;
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;;
;; Convenient way to move between windows
;;
(global-set-key (kbd "C-x <up>") 'windmove-up)
(global-set-key (kbd "C-x <down>") 'windmove-down)
(global-set-key (kbd "C-x <right>") 'windmove-right)
(global-set-key (kbd "C-x <left>") 'windmove-left)


;; Always follow symlinks
(setq vc-follow-symlinks t)

;;
;; Hide Emacs toolbar
;;
(tool-bar-mode -1)

;;
;; Hide menu-bar
;;
(menu-bar-mode -1)

;;
;; Hide scroll-bar
;;
(when (null noninteractive)
  (scroll-bar-mode -1))

;;
;; Alarm bell config
;;
(setq ring-bell-function 'ignore) ;; Completely turn off the alarm bell


;; go-up for eshell
(use-package eshell-up)

;;
;; eshell configuration
;;
(require 'eshell-config-pvj)
(global-set-key (kbd "<f3>") 'eshell)
(global-set-key (kbd "<f4>") 'eshell-here)

;;
;; ansi-term config
;;

;; Disable hl-line-mode for ansi-term
(add-hook 'term-mode-hook (lambda ()
                            (setq-local global-hl-line-mode nil)))

;; Do not show line numbers
(add-hook 'term-mode-hook (lambda ()
                            (linum-mode -1)))

;; Start ansi-term in /bin/bash/
(defvar my-term-shell "/bin/bash")
(defadvice ansi-term (before force-bash)
  (interactive (list my-term-shell)))
(ad-activate 'ansi-term)

;;
;; Highlight the current line
;;
(use-package color)

(defun set-hl-line-color-based-on-theme ()
  "Sets the hl-line face to have no foregorund and a background
    that is 10% darker than the default face's background."
  (set-face-attribute 'hl-line nil
                      :foreground nil
                      :background (color-darken-name (face-background 'default) 10)))

(add-hook 'global-hl-line-mode-hook 'set-hl-line-color-based-on-theme)

(global-hl-line-mode 1)

;; Do not highlight current line in help mode
(add-hook 'help-mode-hook (lambda ()
                            (setq-local global-hl-line-mode nil)))

;;
;; External browser configuration (use Google Chrome)
;;
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "google-chrome")

;;
;; mu4e configuration
;;
(use-package mu4e-config-pvj
  :if (and (string-equal system-type "gnu/linux") (null noninteractive))
  :ensure f
  :demand
  :bind (("<f2>" . mu4e))
  :config
  (progn
    ;;
    ;; imapfilter configuration
    ;; Inspired by https://www.reddit.com/r/emacs/comments/202fon/email_filters_in_mu4e/
    ;;
    (add-hook 'mu4e-update-pre-hook 'pvj/imapfilter)
    (defun pvj/imapfilter ()
      (with-current-buffer (get-buffer-create " *imapfilter*")
        (goto-char (point-max))
        (insert "---\n")
        (call-process "imapfilter" nil (current-buffer) nil "-v")))

    ;; Start mu4e
    (mu4e)

    ;; Make sure the gnutls command-line utils are installed, package
    ;; 'gnutls-bin' in Debian/Ubuntu.
    (use-package smtpmail)

    ;; Use same authinfo file for work and private emails
    (setq message-send-mail-function 'smtpmail-send-it
          starttls-use-gnutls t
          smtpmail-auth-credentials (expand-file-name "~/.authinfo.gpg")
          smtpmail-debug-info t)))

;;
;; Scrolling
;;
;; This seems to be the best way to achieve "smooth scrolling"
;; See - https://www.emacswiki.org/emacs/SmoothScrolling
(setq scroll-conservatively 10000)

;; Also applies to new clients that connect to the Emacs server
(add-to-list 'default-frame-alist '(fullscreen . maximized)) 

;;
;; Company mode (auto completion)
;;
(use-package company
  :config
  (add-hook 'after-init-hook 'global-company-mode)
  (global-set-key (kbd "M-C-/") 'company-complete))

;;
;; Use YASnippet templates
;;
(use-package yasnippet
  :config
  (yas-global-mode 1)
  ;; Remove Yasnippet's default tab key binding
  (define-key yas-minor-mode-map (kbd "<tab>") nil)
  (define-key yas-minor-mode-map (kbd "TAB") nil)
  ;; Set Yasnippet's key binding to shift+tab
  (define-key yas-minor-mode-map (kbd "<backtab>") 'yas-expand)
  ;; Alternatively use Control-c + tab
  (define-key yas-minor-mode-map (kbd "\C-c TAB") 'yas-expand))

;;
;; Highlight current line number
;;
(use-package hlinum
  :demand
  :config
  (hlinum-activate)
  (setq linum-highlight-in-all-buffersp t))

;;
;; For moving buffers around
;;
(use-package buffer-move)

(global-set-key (kbd "<f9>") 'revert-buffer)

;; Page down/up move the point, not the screen.
;; In practice, this means that they can move the
;; point to the beginning or end of the buffer.
(global-set-key [next]
  (lambda () (interactive)
    (condition-case nil (scroll-up)
      (end-of-buffer (goto-char (point-max))))))

(global-set-key [prior]
                (lambda () (interactive)
                  (condition-case nil (scroll-down)
                    (beginning-of-buffer (goto-char (point-min))))))

;;
;;  Mode-line configuration
;;
(defun add-current-dictionary ()
  "Show the current dictionary in the mode-line."
  (add-to-list 'mode-line-buffer-identification 
               '(:eval (concat ispell-current-dictionary " "))))

(add-hook 'text-mode-hook 'add-current-dictionary)

;; Setup smart-mode-line
(use-package smart-mode-line
  :demand
  :config
  (setq sml/theme 'respectful)
  (sml/setup))

;;
;; Git Porcelain inside Emacs
;;
(use-package magit
  :bind
  (("C-x g" . magit-status))
  :config
  (setq magit-repository-directories `("~/git-repos/" "~/git-repos/ovt/externals/" ,user-emacs-directory)))

;;
;; Validate commit messages
;;
(use-package git-commit)

;;
;; Highlight changes in the fringe
;;
(use-package diff-hl
  :config
  (global-diff-hl-mode))

;;
;; Navigation
;;
(require 'navigation-config-pvj)
(define-key global-map (kbd "C-c C-SPC") 'ace-jump-mode)
(global-set-key (kbd "C-l") 'goto-line)
(global-set-key (kbd "<home>") 'pvj/smart-move-to-line-beginning)
(global-set-key (kbd "C-a")    'pvj/smart-move-to-line-beginning)
(global-set-key (kbd "C-z")    'delete-other-windows)
(global-set-key (kbd "C-x o") 'ace-window)

;;
;; Support for Python
;;
(use-package elpy
  :config
  (elpy-enable))

;;
;; Diminish
;;
(require 'diminish-config-pvj)

;;
;; Clojure Interactive Development Environment that Rocks
;;
(use-package cider)

;;
;; Web feed reader
;;
(use-package elfeed
  :config
  (setq elfeed-feeds
        '(("https://newz.dk/rss" it)
          ("http://planet.emacsen.org/atom.xml" emacs)
          ("http://feeds.tv2.dk/nyheder/rss" tv2))))

;;
;; Launch google searches from within Emacs
;;
(use-package google-this
  :config
  (google-this-mode 1))

;;
;; Utility functions
;;
(require 'util-pvj)
(global-set-key (kbd "<f5>") 'pvj/toggle-window-split)

;;
;; ediff configuration
;;
;; To make ‘ediff’ operate on selected-frame use the following:
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
;; To make ediff to be horizontally split use:
(setq ediff-split-window-function 'split-window-horizontally)

;;
;; Compile Elisp sources automatically
;;
(setq load-prefer-newer t)
(use-package auto-compile
  :config
  (auto-compile-on-load-mode)
  (auto-compile-on-save-mode))

(use-package auto-highlight-symbol
  :init (add-hook 'prog-mode-hook 'auto-highlight-symbol-mode)
  :config 
  (setq ahs-idle-interval 1.0)
  (setq ahs-default-range 'ahs-range-whole-buffer) ;; highlight every occurence in buffer
  :bind (:map auto-highlight-symbol-mode-map
              ("M-p" . ahs-backward)
              ("M-n" . ahs-forward)))

(use-package highlight-numbers
  :init (add-hook 'prog-mode-hook 'highlight-numbers-mode))

(use-package google-translate
  :config
  (setq google-translate-default-source-language "da")
  (setq google-translate-default-target-language "en"))

;;
;; Better handling of temporary buffers
;;
(use-package popwin
  :demand
  :config
  (popwin-mode 1))
