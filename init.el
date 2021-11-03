(eval-and-compile
  (customize-set-variable
   'package-archives '(("org" . "https://orgmode.org/elpa/")
		       ("melpa" . "https://melpa.org/packages/")
		       ("gnu" . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package)))

;; BUILTIN PACKAGES CONFIGURATION
(require 'package)
(global-set-key (kbd "C-x p f") #'project-find-file)

;; EVIL MODE
(require 'evil)
(evil-mode 1)
(define-key evil-normal-state-map (kbd "{") 'evil-next-buffer)
(define-key evil-normal-state-map (kbd "}") 'evil-prev-buffer)

;; VIM Style code folding
;;
;;    zc: Close fold (one)
;;    za: Toggle fold (one)
;;    zr: Open folds (all)
;;    zm: Close folds (all)
;;
(add-hook 'prog-mode-hook #'hs-minor-mode)

;; DIFF HL
;; (require 'diff-hl)
;; (global-diff-hl-mode)

(require 'git-gutter+)
(global-git-gutter+-mode)

;; NEOTREE CONFIGURATION
(require 'neotree)
(global-set-key [f8] 'neotree-toggle)
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))

;; DIREX CONFIGURATION
(require 'direx)
(global-set-key (kbd "C-x C-j") 'direx:jump-to-directory)

;; IDO CONFIGURATION
; (setq ido-enable-flex-matching t)
; (setq ido-everywhere t)
; (ido-mode 1)

;; VISUAL FILL MODE CONFIGURATION
(require 'visual-fill-column)
(add-hook 'org-mode-hook 'auto-fill-mode)
(add-hook 'visual-line-mode-hook #'visual-fill-column-mode)
(add-hook 'visual-line-mode-hook #'adaptive-wrap-prefix-mode)

;; GENERAL CONFIGURATION
(set-face-attribute 'default nil :height 135)
(add-hook 'prog-mode-hook 'global-display-line-numbers-mode)
(delete-selection-mode t)
(setq cursor-type'block)
(setq ring-bell-function 'ignore)
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024)) ;; 1mb buffer
(setq auto-save-default nil)
(setq make-backup-files nil)
(setq create-lockfiles nil)
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)
(display-time-mode t)
(tool-bar-mode 0)
(scroll-bar-mode -1)
(put 'narrow-to-region 'disabled nil)
(show-paren-mode t)
(setq gc-cons-threshold 20000000) ;; 20MB
(setq large-file-warning-threshold 200000000) ;; Warn on 20MB
(fset 'yes-or-no-p 'y-or-n-p)
(global-auto-revert-mode t)
(defun turn-off-eldoc () (eldoc-mode -1))
(add-hook 'eval-expression-minibuffer-setup-hook #'turn-off-eldoc)
;; set default tab char's display width to 4 spaces
(setq-default tab-width 4) ; emacs 23.1 to 26 default to 8
;; set current buffer's tab char's display width to 4 spaces
(setq tab-width 4)
(set-frame-font "Hermit")

;; DELETE TRAILIN WHITESPACES
(add-hook 'before-save-hook '(lambda()
  (when (not (or (derived-mode-p 'markdown-mode)))
  (delete-trailing-whitespace))))

;; Save cursor positions
(setq save-place-file "~/.emacs.d/saveplace")
(if (version<= emacs-version "25.1")
    (progn
      (setq-default save-place t)
      (require 'saveplace))
  (save-place-mode 1))

;; Safeguard, so this only runs on Linux (or MacOS)
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

;; WINNER MODE C-c Left / C-c Right
(when (fboundp 'winner-mode)
  (winner-mode 1))

;; SO LONG
(if (version<= "27.1" emacs-version)
    (global-so-long-mode 1))

;; MOVE CURRENT LINE UP OR DOWN alt-up / atl-down
(defun move-line-up ()
  "Move up the current line."
  (interactive)
  (transpose-lines 1)
  (forward-line -2)
  (indent-according-to-mode))

(defun move-line-down ()
  "Move down the current line."
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1)
  (indent-according-to-mode))

(global-set-key (kbd "M-<down>") 'move-line-down)
(global-set-key (kbd "M-<up>") 'move-line-up)

(dolist (hook '(text-mode-hook))
  (add-hook hook (lambda () (flyspell-mode 1))))

;; Open file and specify line nubmer E.G: emacs main.go:12
(defadvice server-visit-files (before parse-numbers-in-lines (files proc &optional nowait) activate)
  "Open file with emacsclient with cursors positioned on requested line.
Most of console-based utilities prints filename in format
'filename:linenumber'.  So you may wish to open filename in that format.
Just call:
  emacsclient filename:linenumber
and file 'filename' will be opened and cursor set on line 'linenumber'"
  (ad-set-arg 0
              (mapcar (lambda (fn)
                        (let ((name (car fn)))
                          (if (string-match "^\\(.*?\\):\\([0-9]+\\)\\(?::\\([0-9]+\\)\\)?$" name)
                              (cons
                               (match-string 1 name)
                               (cons (string-to-number (match-string 2 name))
                                     (string-to-number (or (match-string 3 name) ""))))
                            fn))) files)))

(use-package exec-path-from-shell
  :ensure t
  :config
  (exec-path-from-shell-initialize))

(require 'flycheck)
(add-hook 'after-init-hook #'global-flycheck-mode)

(require 'comment-tags)
(setq comment-tags-keymap-prefix (kbd "C-c t"))
(with-eval-after-load "comment-tags"
  (setq comment-tags-keyword-faces
       `(;; A concrete TODO with actionable steps
          ("TODO" . ,(list :weight 'bold :foreground "#2ecc71"))
          ("FIXME" . ,(list :weight 'bold :foreground "#ff7979"))
          ("HACK" . ,(list :weight 'bold :foreground "#f1c40f"))
          ("BUG" . ,(list :weight 'bold :foreground "#e84118"))
          ("NOTE" . ,(list :weight 'bold :foreground "#dff9fb"))
          ("INFO" . ,(list :weight 'bold :foreground "#bdc3c7"))))
  (setq comment-tags-comment-start-only t
        comment-tags-require-colon t
        comment-tags-case-sensitive t
        comment-tags-show-faces t
        comment-tags-lighter nil))
(add-hook 'prog-mode-hook 'comment-tags-mode)
(add-hook 'conf-mode-hook 'comment-tags-mode)

(use-package which-key
  :ensure t
  :config
  (which-key-mode))

(use-package expand-region
  :ensure t
  :bind (("C-=" . er/expand-region)
	 ("C--" . er/contract-region)))

;; JSON-MODE CONFIGURATION
(use-package json-mode
  :ensure t)

;; WEB-MODE CONFIGURATION
(setq web-mode-markup-indent-offset 2)
(setq web-mode-code-indent-offset 2)
(setq web-mode-css-indent-offset 2)
(use-package web-mode
  :ensure t
  :mode (("\\.js\\'" . web-mode)
	 ("\\.jsx\\'" .  web-mode)
	 ("\\.ts\\'" . web-mode)
	 ("\\.tsx\\'" . web-mode)
	 ("\\.html\\'" . web-mode))
  :commands web-mode)

;; COMPANY CONFIGURATION
(setq company-minimum-prefix-length 1
      company-idle-delay 0.0)
(use-package company
  :ensure t
  :config (global-company-mode t))

;; MAGIG STATUS CONFIGURATION
(use-package magit
  :ensure t
  :bind (
		 ("C-x g" . magit-status)
		 ("C-x d" . magit-diff-buffer-file)
		 ))

;; LSP-MODE CONFIGURATION
(setq lsp-log-io nil) ;; Don't log everything = speed
(setq lsp-keymap-prefix "C-c l")
(setq lsp-restart 'auto-restart)
(setq lsp-ui-sideline-show-diagnostics t)
(setq lsp-ui-sideline-show-hover t)
(setq lsp-ui-sideline-show-code-actions t)

(helm-mode)
(require 'helm-xref)
(define-key global-map [remap find-file] #'helm-find-files)
(define-key global-map [remap execute-extended-command] #'helm-M-x)
(define-key global-map [remap switch-to-buffer] #'helm-mini)

(which-key-mode)
(add-hook 'c-mode-hook 'lsp)
(add-hook 'c++-mode-hook 'lsp)

(setq gc-cons-threshold (* 100 1024 1024)
      read-process-output-max (* 1024 1024)
      treemacs-space-between-root-nodes nil
      company-idle-delay 0.0
      company-minimum-prefix-length 1
      lsp-idle-delay 0.1)  ;; clangd is fast

(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
  (require 'dap-cpptools)
  (yas-global-mode))

;; LSP MODE CONFIGURATION
;;(use-package lsp-mode
;;  :ensure t
;;  :hook (
;;	 (web-mode . lsp-deferred)
;;	 (lsp-mode . lsp-enable-semantic-highlighting))
;;  :commands lsp-deferred)

;; LSP UI CONFIGURATION
(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

(defun enable-minor-mode (my-pair)
  "Enable minor mode if filename match the regexp.  MY-PAIR is a cons cell (regexp . minor-mode)."
  (if (buffer-file-name)
      (if (string-match (car my-pair) buffer-file-name)
	  (funcall (cdr my-pair)))))

;; EDITOR ZOOM
;; C-0/C-1
(defun zoom-in ()
  (interactive)
  (let ((x (+ (face-attribute 'default :height)
              10)))
    (set-face-attribute 'default nil :height x)))
(defun zoom-out ()
  (interactive)
  (let ((x (- (face-attribute 'default :height)
              10)))
    (set-face-attribute 'default nil :height x)))

(define-key global-map (kbd "C-1") 'zoom-in)
(define-key global-map (kbd "C-0") 'zoom-out)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector
   (vector "#2d2d2d" "#f2777a" "#99cc99" "#ffcc66" "#6699cc" "#cc99cc" "#66cccc" "#cccccc"))
 '(beacon-color "#f2777a")
 '(custom-enabled-themes '(sanityinc-tomorrow-eighties))
 '(custom-safe-themes
   '("1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" "82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "d14f3df28603e9517eb8fb7518b662d653b25b26e83bd8e129acea042b774298" "6b5c518d1c250a8ce17463b7e435e9e20faa84f3f7defba8b579d4f5925f60c1" "7661b762556018a44a29477b84757994d8386d6edee909409fabe0631952dad9" "83e0376b5df8d6a3fbdfffb9fb0e8cf41a11799d9471293a810deb7586c131e6" "fa2b58bb98b62c3b8cf3b6f02f058ef7827a8e497125de0254f56e373abee088" "bffa9739ce0752a37d9b1eee78fc00ba159748f50dc328af4be661484848e476" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" default))
 '(fci-rule-color "#515151")
 '(flycheck-color-mode-line-face-to-color 'mode-line-buffer-id)
 '(frame-background-mode 'dark)
 '(global-display-line-numbers-mode t)
 '(hl-todo-keyword-faces
   '(("TODO" . "#dc752f")
	 ("NEXT" . "#dc752f")
	 ("THEM" . "#2d9574")
	 ("PROG" . "#4f97d7")
	 ("OKAY" . "#4f97d7")
	 ("DONT" . "#f2241f")
	 ("FAIL" . "#f2241f")
	 ("DONE" . "#86dc2f")
	 ("NOTE" . "#b1951d")
	 ("KLUDGE" . "#b1951d")
	 ("HACK" . "#b1951d")
	 ("TEMP" . "#b1951d")
	 ("FIXME" . "#dc752f")
	 ("XXX+" . "#dc752f")
	 ("\\?\\?\\?+" . "#dc752f")))
 '(inhibit-startup-screen t)
 '(org-fontify-done-headline nil)
 '(org-fontify-todo-headline nil)
 '(package-archives
   '(("org" . "https://orgmode.org/elpa/")
	 ("melpa" . "https://melpa.org/packages/")
	 ("gnu" . "https://elpa.gnu.org/packages/")))
 '(package-selected-packages
   '(rainbow-mode all-the-icons lsp-ui lsp-mode sokoban git-gutter+ diff-hl fzf gruvbox-theme web-mode-edit-element typescript-mode direx spacemacs-theme color-theme-sanityinc-tomorrow neotree evil))
 '(pdf-view-midnight-colors '("#fdf4c1" . "#1d2021"))
 '(show-paren-mode t)
 '(vc-annotate-background nil)
 '(vc-annotate-color-map
   '((20 . "#f2777a")
	 (40 . "#f99157")
	 (60 . "#ffcc66")
	 (80 . "#99cc99")
	 (100 . "#66cccc")
	 (120 . "#6699cc")
	 (140 . "#cc99cc")
	 (160 . "#f2777a")
	 (180 . "#f99157")
	 (200 . "#ffcc66")
	 (220 . "#99cc99")
	 (240 . "#66cccc")
	 (260 . "#6699cc")
	 (280 . "#cc99cc")
	 (300 . "#f2777a")
	 (320 . "#f99157")
	 (340 . "#ffcc66")
	 (360 . "#99cc99")))
 '(vc-annotate-very-old-color nil)
 '(window-divider-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
