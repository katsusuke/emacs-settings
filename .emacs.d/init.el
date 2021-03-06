;; ↓等幅フォントチェック用
;; 12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
;; あいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえおあいうえお
;; メモ
;; 現在有効なキーボードショートカットを表示するには<F1> b
;;
;; .emacs.el を再読み込みするには
;; C-x C-s または Command + s
;; M-x load-file RET ~/.emacs.el RET
;;
;; Dependencies
;;    cask
;;    marked (npmで入れる)
;;    pry
;;    pry-doc
;;    method_source
;;    rubocop
;;    ruby-lint
;;    cmigemo (日本語検索)
;;    aspell
;;    ※ migemo のインストール時に文字コードエラーが出るので euc-jp-unix を選んでやること
;;    wakatime (pyenv + pipで入れる)

;; custom-set-variables は別ファイルにする
(setq custom-file (locate-user-emacs-file "custom.el"))
; custom-set-variables 変数更新のためにinit.el が上書きされるのを防ぐ
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

(setq debug-on-message t)

;; initialize straight
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(if (file-exists-p "~/.emacs.d/.env.el")
    (load "~/.emacs.d/.env.el"))

(defun set-font-size (height)
  (interactive "nHeight:")
  (set-face-attribute 'default (selected-frame) :height height))

;; GUIの設定が後から動くとなんかうざい感じになるので先に動かす
(if (eq window-system 'w32)
    (progn
      (custom-set-faces
       '(default ((t (:inherit nil :stipple nil :background "black" :foreground "white" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 98 :width normal :foundry "outline" :family "Osaka－等幅")))))
      (set-frame-parameter nil 'alpha 85)
      ;; デフォルトの文字コードはUTF-8にする
      (set-default-coding-systems 'utf-8)
      (prefer-coding-system 'utf-8-unix)

      (setq grep-command "grep -n -e ")
      (setq grep-program "grep")
      (defun open-filer()
	"Open current directory by filer"
	(interactive)
	(shell-command "explorer /e,."))
      (setq default-input-method "W32-IME")
      (setq-default w32-ime-mode-line-state-indicator "[--]")
      (setq w32-ime-mode-line-state-indicator-list '("[--]" "[あ]" "[--]"))
      (w32-ime-initialize)
      ;; 日本語入力時にカーソルの色を変える設定 (色は適宜変えてください)
      (add-hook 'w32-ime-on-hook '(lambda () (set-cursor-color "coral4")))
      (add-hook 'w32-ime-off-hook '(lambda () (set-cursor-color "white")))

      ;; 以下はお好みで設定してください
      ;; 全てバッファ内で日本語入力中に特定のコマンドを実行した際の日本語入力無効化処理です
      ;; もっと良い設定方法がありましたら issue などあげてもらえると助かります

      ;; ミニバッファに移動した際は最初に日本語入力が無効な状態にする
      (add-hook 'minibuffer-setup-hook 'deactivate-input-method)

      ;; isearch に移行した際に日本語入力を無効にする
      (add-hook 'isearch-mode-hook '(lambda ()
				      (deactivate-input-method)
				      (setq w32-ime-composition-window (minibuffer-window))))
      (add-hook 'isearch-mode-end-hook '(lambda () (setq w32-ime-composition-window nil)))

      ;; helm 使用中に日本語入力を無効にする
      (advice-add 'helm :around '(lambda (orig-fun &rest args)
				   (let ((select-window-functions nil)
					 (w32-ime-composition-window (minibuffer-window)))
				     (deactivate-input-method)
				     (apply orig-fun args))))
      ))

;; ns
(if (eq window-system 'ns)
    (progn
      (set-frame-parameter (selected-frame) 'alpha '(75 . 65))
      (setq ns-pop-up-frames nil) ;; コマンドから open -a Emacs.app されたときに新しいフレームを開かない
      ;; keybind
      (global-unset-key "\C-z") ;; C-zで最小化してうざいので無効に
      (setq mac-option-modifier 'meta)   ;; Option キーを Meta キーとして使う
      (setq mac-command-modifier 'super) ;; Command キーを Super キーとして使う
      ;; Mac 標準キーバインド
      (global-set-key [(super v)] 'yank)
      (global-set-key [(super c)] 'kill-ring-save)
      (global-set-key [(super s)] 'save-buffer)
      (global-set-key [(super x)] 'kill-region)
      ;; バックスラッシュ入力
      (define-key global-map [2213] nil)
      (define-key global-map [67111077] nil)
      (define-key global-map [134219941] nil)
      (define-key global-map [201328805] nil)
      (define-key function-key-map [2213] [?\\])
      (define-key function-key-map [67111077] [?\C-\\])
      (define-key function-key-map [134219941] [?\M-\\])
      (define-key function-key-map [201328805] [?\C-\M-\\])
      (define-key global-map [3420] nil)
      (define-key global-map [67112284] nil)
      (define-key global-map [134221148] nil)
      (define-key global-map [201330012] nil)
      (define-key function-key-map [3420] [?\\])
      (define-key function-key-map [67112284] [?\C-\\])
      (define-key function-key-map [134221148] [?\M-\\])
      (define-key function-key-map [201330012] [?\C-\M-\\])

      ;; カーソル行ハイライト
      (defface hlline-face
      	'((((class color)
      	    (background dark))
      	   ;;(:background "dark state gray"))
      	   (:background "gray10"
      			:underline "gray4"))
      	  (((class color)
      	    (background light))
      	   (:background "ForestGreen"
      			:underline nil))
      	  (t ()))
      	"*Face used by hl-line.")
      (setq hl-line-face 'hlline-face)
      ;; (setq hl-line-face 'underline)
      (global-hl-line-mode)

      ;; Show filename on titlebar
      (setq frame-title-format (format "%%f - Emacs@%s" (system-name)))

      ;; disable x-popup-dialog
      (defadvice yes-or-no-p (around prevent-dialog activate)
	"Prevent yes-or-no-p from activating a dialog"
	(let ((use-dialog-box nil))
	  ad-do-it))
      (defadvice y-or-n-p (around prevent-dialog-yorn activate)
	"Prevent y-or-n-p from (and )ctivating a dialog"
	(let ((use-dialog-box nil))
	  ad-do-it))

      (setenv "PATH" (format "%s:%s" (getenv "PATH") "/usr/local/bin"))
      (setenv "PATH" (format "%s:%s" (getenv "PATH") "~/.go/bin"))
      (setenv "PATH" (format "%s:%s" (getenv "PATH") "~/.pyenv/shims"))
      (setenv "PATH" (format "%s:%s" (getenv "PATH") "~/.rbenv/shims"))
      (setq exec-path (split-string (getenv "PATH") ":"))
      ;; fix drag n drop
      (global-set-key [C-M-s-drag-n-drop] 'ns-drag-n-drop)
      ))

; X用
(if (eq window-system 'x)
    (progn
      (define-key function-key-map [backspace] [8])
      (put 'backspace 'ascii-character 8)))

(if (not(eq window-system 'w32))
    (add-to-list 'load-path "/usr/local/share/emacs/site-lisp"))

(setq-default indent-tabs-mode nil)
(defalias 'yes-or-no-p 'y-or-n-p)

(straight-use-package 'use-package)
(setq use-package-verbose t)
(setq straight-use-package-by-default t)

(use-package auto-highlight-symbol :config (global-auto-highlight-symbol-mode t))
(use-package multiple-cursors :config (global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines))
(use-package mode-icons :config (mode-icons-mode))
(use-package mmm-mode)
(use-package request)
(use-package graphql-mode)
(use-package ag :commands ag)
(use-package pt :commands pt)
(use-package helm-ag :commands helm-ag)
(use-package helm-pt :commands helm-pt)
(use-package helm-swoop)
(use-package rbenv
  :config
  (setq rbenv-executable (executable-find "rbenv"))
  (global-rbenv-mode))
(use-package helm-rdefs)
(use-package rhtml-mode)
(use-package coffee-mode)
(use-package helm-ghq)
(use-package hiwin)
(use-package nginx-mode)
(use-package rubocop)
(use-package groovy-mode)
(use-package dash-at-point
  :commands
  (dash-at-point dash-at-point-with-docset)
  :bind
  (("\C-cd" . dash-at-point)
   ("\C-ce" . dash-at-point-with-docset)))

(use-package wakatime-mode
  :config
  ;; wakatime-mode
  (if (and (executable-find "wakatime") (boundp 'wakatime-api-key))
      (global-wakatime-mode t)))
(use-package slim-mode)
(use-package terraform-mode)
(use-package alchemist)
(use-package ac-alchemist)
(use-package vue-mode)
(use-package prettier-js)
(use-package flycheck-rust)
(use-package ng2-mode)


;; リージョンをハイライト
;; C-g で解除(マークは残っているがリージョンは無効)
;; C-x C-x でリージョンを復活
;; M-; ハイライトがあればコメントアウト
(transient-mark-mode 1)

;; ウインドウ移動をShift+矢印で
(windmove-default-keybindings)

(use-package visual-regexp
  :config
  (global-set-key (kbd "M-%") 'vr/query-replace))

;; 最近使ったファイルを時々保存
(use-package recentf
  :config
  (setq recentf-max-saved-items 2000)
  (setq recentf-exclude '(".recentf" "^/ssh:"))
  (setq recentf-auto-cleanup 'never)

  (setq recentf-auto-save-timer
        (run-with-idle-timer 30 t 'recentf-save-list))
  (recentf-mode 1)
  ;; recentf の メッセージをエコーエリア(ミニバッファ)に表示しない
  ;; (*Messages* バッファには出力される)
  (defun recentf-save-list-inhibit-message:around (orig-func &rest args)
    (setq inhibit-message t)
    (apply orig-func args)
    (setq inhibit-message nil)
    'around)
  (advice-add 'recentf-cleanup   :around 'recentf-save-list-inhibit-message:around)
  (advice-add 'recentf-save-list :around 'recentf-save-list-inhibit-message:around)
  )

;; カーソル位置の単語をハイライト
;; M-<left>	ahs-backward	前のシンボルへ移動
;; M-<right>	ahs-forward	次のシンボルへ移動
;; M-s-<left>	ahs-backward-difinition	?
;; M-s-<right>	ahs-forward-definition	?
;; M--	ahs-back-to-start	最初のカーソル位置のシンボルへ移動
;; C-x C-'	ahs-change-range	ハイライトする範囲を表示しているディスプレイの範囲かバッファ全体かを切り替える
;; C-x C-a	ahs-edit-mode	ハイライトしているシンボルを一括でrenameする
(use-package auto-highlight-symbol :config (global-auto-highlight-symbol-mode t))

;; 日本語インクリメンタル検索
(use-package migemo
  :config
  (setq migemo-command "cmigemo")
  (setq migemo-options '("-q" "--emacs"))
  (setq migemo-user-dictionary nil)
  (setq migemo-regex-dictionary nil)
  (setq migemo-coding-system 'utf-8-unix)
  ;; Set your installed path
  (if (eq window-system 'w32)
      (setq migemo-dictionary (expand-file-name "~/.emacs.d/share/migemo/dict/utf-8/migemo-dict")))
  (if (eq window-system 'ns)
      (setq migemo-dictionary "/usr/local/opt/cmigemo/share/migemo/utf-8/migemo-dict"))
  (migemo-init)
  )

;; バックアップ関係
;; ロックファイルを作らない
(setq create-lockfiles nil)

;; backup-directory-alist は以下の構造を持つ
;; (regexp . directory)
;; regexp に一致したファイルのバックアップが directory に作られる
(setq backup-directory-alist (cons (cons "\\.*$" (expand-file-name "~/.backup"))
				   backup-directory-alist))

(setq version-control t ;; Use version numbers for backups
      kept-new-versions 16 ;; Number of newest versions to keep
      kept-old-versions 2 ;; Number of oldest versions to keep
      delete-old-versions t ;; Ask to delete excess backup versions?
      backup-by-copying-when-linked t) ;; Copy linked files, don't rename.
(defun force-backup-of-buffer ()
  (let ((buffer-backed-up nil))
    (backup-buffer)))
(add-hook 'before-save-hook  'force-backup-of-buffer)

;; http://namazu.org/~satoru/diary/?200203c&to=200203272#200203272
;; 編集中のファイルを開き直す
;; - yes/no の確認が不要;;   - revert-buffer は yes/no の確認がうるさい
;; - 「しまった! 」というときにアンドゥで元のバッファの状態に戻れる
;;   - find-alternate-file は開き直したら元のバッファの状態に戻れない
;;
(defun reopen-file ()
  (interactive)
  (let ((file-name (buffer-file-name))
        (old-supersession-threat
         (symbol-function 'ask-user-about-supersession-threat))
        (point (point)))
    (when file-name
      (fset 'ask-user-about-supersession-threat (lambda (fn)))
      (unwind-protect
          (progn
            (erase-buffer)
            (insert-file file-name)
            (set-visited-file-modtime)
            (goto-char point))
        (fset 'ask-user-about-supersession-threat
              old-supersession-threat)))))

;画面端でおりかえす
(setq truncate-partial-width-windows nil)

;; upcase[C-x C-u] downcase[C-x C-l] を問い合わせなしで実行
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

;; Don't show Welcome Page
(setq inhibit-startup-message t)
;; Stop beep and flush
(setq ring-bell-function 'ignore)

;; (global-set-key "\C-h" 'backward-delete-char)
;; (global-set-key "\177" 'delete-char)
;goto-line はデフォルトでは M-g g
;(global-set-key "\M-g" 'goto-line)
(global-set-key "\C-h" 'delete-backward-char)
;; TABをBackspaceで消す
(global-set-key [backspace] 'backward-delete-char)
;(global-set-key "\C-@" 'set-mark-command)

;ファイルの先頭に #! が含まれているとき、自動的に chmod +x を行ってくれます。
(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)

(use-package projectile)
(use-package helm-projectile)

(use-package helm
  :config
  (helm-mode)
  (helm-migemo-mode 1)
  (define-key global-map (kbd "C-;") 'helm-mini)
  (define-key global-map (kbd "M-x")     'helm-M-x)
  (define-key global-map (kbd "C-x C-f") 'helm-find-files)
  ;; helm-swoop
  (setq helm-swoop-pattern "") ;; TODO:delte me. hotfix helm-swoop-from-isearch
  (global-set-key (kbd "M-i") 'helm-swoop)
  (global-set-key (kbd "M-I") 'helm-swoop-back-to-last-point)
  (define-key isearch-mode-map (kbd "M-i") 'helm-swoop-from-isearch)

  ;; For helm-find-files etc.
  (define-key helm-find-files-map (kbd "TAB") 'helm-execute-persistent-action)

  ;helm でC-k の挙動を通常のバッファと同等にする
  (setq helm-delete-minibuffer-contents-from-point t)
  (defadvice helm-delete-minibuffer-contents (before helm-emulate-kill-line activate)
    "Emulate `kill-line' in helm minibuffer"
    (kill-new (buffer-substring (point) (field-end))))

  (require 'helm-buffers)
  (defadvice helm-buffers-sort-transformer (around ignore activate)
    (setq ad-return-value (ad-get-arg 0)))

  (setq helm-ag-insert-at-point 'symbol)

  ;; helm-projectile
  (setq projectile-keymap-prefix (kbd "C-c p"))
  (projectile-mode)
  (helm-projectile-on)

  (setq helm-mini-default-sources
    '(helm-source-projectile-files-list
      helm-source-projectile-projects
      helm-source-recentf
      helm-source-buffer-not-found))

  )

(use-package whitespace
  :commands whitespace-mode
  :hook
  ((enh-ruby-mode . whitespace-mode))
  :config
  (setq whitespace-style '(face           ; faceで可視化
                           trailing       ; 行末
                           tabs           ; タブ
                           spaces         ; スペース
                           empty          ; 先頭/末尾の空行
                           space-mark     ; 表示のマッピング
                           tab-mark
                           ))

    ;; 全角スペース的なもの
  (setq alt-spaces "\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u200B\u3000\uFEFF")
  (setq space-marks
        (mapcar
         (lambda (c) (list 'space-mark c [?\u25a1]))
         alt-spaces))

  (setq whitespace-display-mappings
        (cl-concatenate
         'list
         space-marks
         ;; WARNING: the mapping below has a problem.
         ;; When a TAB occupies exactly one column, it will display the
         ;; character ?\xBB at that column followed by a TAB which goes to
         ;; the next TAB column.
         ;; If this is a problem for you, please, comment the line below.
         '((tab-mark ?\t [?\u00BB ?\t] [?\\ ?\t]))))

  (setq whitespace-space-regexp (concat "\\([" alt-spaces "]+\\)"))

  ;; 保存前に自動でクリーンアップ
  (setq whitespace-action '(auto-cleanup))

  (let ((my/bg-color "black"))
    (set-face-attribute 'whitespace-trailing nil
                        :background my/bg-color
                        :foreground "DeepPink"
                        :underline t)
    (set-face-attribute 'whitespace-tab nil
                        :background my/bg-color
                        :foreground "LightSkyBlue"
                        :underline t)
    (set-face-attribute 'whitespace-space nil
                        :background my/bg-color
                        :foreground "GreenYellow"
                        :weight 'bold)
    (set-face-attribute 'whitespace-empty nil
                        :background my/bg-color))

  )

(use-package company
  :config
  (global-company-mode)
  ;; aligns annotation to the right hand side
  (setq company-tooltip-align-annotations t)
  (setq company-minimum-prefix-length 2))

(use-package company-tabnine
  :config
  (add-to-list 'company-backends #'company-tabnine)
  ;; Trigger completion immediately.
  (setq company-idle-delay 0)
  ;; Number the candidates (use M-1, M-2 etc to select completions).
  (setq company-show-numbers t)
  )

(use-package lsp-mode
  :hook
  ((web-mode . lsp)
   (scss-mode . lsp)
   (sass-mode . lsp)
   (vue-mode . lsp)
   (js-mode . lsp)
   )
  :config
  (setq
   web-mode-enable-auto-quoting nil
   lsp-enable-snippet nil
   lsp-auto-configure t
   lsp-auto-guess-root t
   lsp-completion-provider :capf
   lsp-prefer-flymake nil
   lsp-clients-angular-language-server-command
        '("node"
          "node_modules/@angular/language-server"
          "--ngProbeLocations"
          "node_modules"
          "--tsProbeLocations"
          "node_modules"
          "--stdio")
   )
  )

(use-package lsp-ui
  :after (lsp-mode)
  :config
  (message "lsp-ui-mode :custom")
  (setq
    lsp-ui-flycheck-enable t
    lsp-ui-doc-max-width 150
    lsp-ui-doc-max-height 30
    ))

(use-package lsp-pyright
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp))))  ; or lsp-deferred

(use-package tree-sitter
  :hook
  ((typescript-mode . tree-sitter-mode)
   (enh-ruby-mode . tree-sitter-mode)))
(use-package tree-sitter-langs)

(use-package helm-lsp :commands helm-lsp-workspace-symbol)

(use-package tide
  :after (typescript-mode company flycheck)
  :hook ((typescript-mode . tide-setup)
         (typescript-mode . tide-hl-identifier-mode)))

(use-package flycheck
  :config
  (message "flycheck :config")
  (global-flycheck-mode))

;; リモートのファイルを編集するTRAMP
(use-package tramp
  :config
  (setq tramp-default-method "ssh"))

;;; Languages

;; vbnet-mode
(use-package vbnet-mode
  :mode "\\.\\(frm\\|bas\\|cls\\|vb\\)$"
  :load-path "./site-lisp"
  :config
  (turn-on-font-lock)
  (turn-on-auto-revert-mode)
  (setq vbnet-mode-indent 4)
  (setq vbnet-want-imenu t))

;; CSharp-mode
(use-package csharp-mode
  :mode "\\.cs$"
  :config
  (c-set-offset 'substatement-open '0)
  (setq tab-width  4
        c-basic-offset 4))

;; markdown-mode
(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("\\.md\\'" . gfm-mode))
  :init (lambda()
	  (setq markdown-command "/usr/local/bin/multimarkdown")
	  (setq markdown-open-command "marked2")))

;; grep の結果画面は画面端で折り返さないけど、
;; コンパイルの結果画面は画面端で折り返す
(add-hook 'compilation-mode-hook
          '(lambda ()
	     (prin1 major-mode)
	     (if (member major-mode (list 'grep-mode 'ag-mode 'pt-mode))
		    (setq truncate-lines t))))



(use-package enh-ruby-mode
  :mode "\\(\\.\\(rb\\|rake\\|ruby\\|thor\\|jbuilder\\|cap\\)\\|Gemfile\\)$"
  :config
  (add-to-list 'interpreter-mode-alist '("ruby" . enh-ruby-mode))
  ;; 保存時にmagic commentを追加しないようにする
  (defadvice enh-ruby-mode-set-encoding (around stop-enh-ruby-mode-set-encoding)
    "If enh-ruby-not-insert-magic-comment is true, stops enh-ruby-mode-set-encoding."
    (if (and (boundp 'enh-ruby-not-insert-magic-comment)
             (not enh-ruby-not-insert-magic-comment))
        ad-do-it))
  (ad-activate 'enh-ruby-mode-set-encoding)
  (setq-default enh-ruby-not-insert-magic-comment t)

  ;; hash-rocket を1.9記法に変換する
  (defun ruby-anti-hash-rocket ()
    (interactive)
    (beginning-of-line)
    (setq current-line (count-lines (point-min) (point)))
    (setq replaced (replace-regexp-in-string ":\\([a-z0-9_]+\\)\s*=>" "\\1:" (buffer-string)))
    (erase-buffer)
    (insert replaced)
    (goto-line (+ 1 current-line))
    (beginning-of-line)
    )
  )

;; HAML
;; C-i でインデント C-I でアンインデント
(use-package haml-mode
  :mode "\\.haml$"
  :config
  (add-to-list 'write-file-functions 'delete-trailing-whitespace)
  (c-set-offset 'substatement-open '0)
  (setq tab-width 8))


(use-package ggtags
  :commands ggtags-mode
  :init
  (setq ggtags-mode-hook
        '(lambda ()
           (local-set-key "\M-t" 'ggtags-find-definition) ;; 定義にジャンプ
           (local-set-key "\M-r" 'ggtags-find-reference)  ;; 参照を検索
           (local-set-key "\M-s" 'ggtags-find-symbol)     ;; 定義にジャンプ
	   (setq ggtags-completing-read-function nil)
	   (helm-mode 1)
	   ))
  (global-set-key "\M-e" 'ggtags-pop-stack)               ;; スタックを戻る
  :config
  ;; c-mode-common
  (add-hook 'c-mode-common-hook
            (lambda ()
              (when (derived-mode-p 'c-mode 'c++-mode 'java-mode 'web-mode)
                (ggtags-mode 1)))))

;; c-mod
(add-hook
 'c-mode-hook
 '(lambda ()
    ;; cedit
    (semantic-mode 1)
    (cpp-highlight-buffer t)
    (setq semantic-default-submodes
         '(
           global-semantic-idle-scheduler-mode
           global-semantic-idle-completions-mode
           global-semanticdb-minor-mode
           global-semantic-decoration-mode
           global-semantic-highlight-func-mode
           global-semantic-stickyfunc-mode
           global-semantic-mru-bookmark-mode
           ))
    (setq tab-width 4
          c-basic-offset 4
          indent-tabs-mode 1)))

;; c++-mode
(add-hook
 'c++-mode-hook
 '(lambda ()
    ;; cedit
    (semantic-mode 1)
    (cpp-highlight-buffer t)
    (setq semantic-default-submodes
         '(
           global-semantic-idle-scheduler-mode
           global-semantic-idle-completions-mode
           global-semanticdb-minor-mode
           global-semantic-decoration-mode
           global-semantic-highlight-func-mode
           global-semantic-stickyfunc-mode
           global-semantic-mru-bookmark-mode
           ))
    ;; gtags
    (setq tab-width 4
          c-basic-offset 4
          indent-tabs-mode 1)))

;; add-node-modules-path
(use-package add-node-modules-path
  :hook
  ((js-mode . add-node-modules-path)
   (typescript-mode . add-node-modules-path)
   (web-mode . add-node-modules-path)
   (vue-mode . add-node-modules-path))
  :commands
  add-node-modules-path)


;; YAML-mode
(use-package yaml-mode
  :mode "\\.yml$"
  :config
  (add-to-list 'write-file-functions 'delete-trailing-whitespace))

(use-package yaml-tomato
  :commands
  (yaml-tomato-show-current-path yaml-tomato-copy))

;; css-mode
(add-hook 'css-mode-hook
	  '(lambda ()
	     (setq css-indent-offset 2)))

;; scss-mode
(use-package scss-mode
  :mode "\\.scss$"
  :config
  (setq scss-compile-at-save nil))

;; sass-mode
(use-package sass-mode
  :mode "\\.sass\\'")

;; html-mode
(add-hook 'html-mode-hook
          (lambda()
            (setq sgml-basic-offset 2)))

;; nodenv by shim
(use-package shim
  :straight (:host github :repo "twlz0ne/shim.el")
  :hook
  ((js-mode . shim-mode)
   (typescript-mode . shim-mode)
   (web-mode . shim-mode)
   (vue-mode . shim-mode))
  :config
  (shim-init-node)
  (shim-register-mode 'node 'typescript-mode))

;; js-mode (javascript-mode)
(add-hook 'js-mode-hook
          (lambda ()
            (setq js-indent-level 2)))

(use-package typescript-mode
  :mode "\\.ts$"
  :config
  (setq typescript-indent-level 2)
  (flycheck-add-mode 'javascript-eslint 'web-mode)
  ;(flycheck-add-next-checker 'lsp 'javascript-eslint)
  )

(if (or (eq window-system 'w32) (eq window-system 'ns) (eq window-system 'x))
    (progn
      (use-package server
        ;; クライアントを終了するとき終了するかどうかを聞かない
        ;; サーバ起動
        :config
        (unless (server-running-p)
          (progn
            (server-start)
            (remove-hook 'kill-buffer-query-functions 'server-kill-buffer-query-function))))))

;; 選択中のフレームを強調
(hiwin-activate)
(set-face-background 'hiwin-face "gray8")

;;web-mode
(use-package web-mode
  :mode (("\\.\\(ctp\\|php\\|php5\\|inc\\)$" . web-mode)
         ("\\.phtml$"     . web-mode)
         ("\\.tpl\\.php$" . web-mode)
         ("\\.jsp$"       . web-mode)
         ("\\.as[cp]x$"   . web-mode)
         ("\\.erb$"       . web-mode)
         ("\\.ctp$"     . web-mode)
         ("\\.tsx$"     . web-mode))
  :init
  (add-hook 'web-mode-hook
             '(lambda ()
                (when (string-equal "tsx" (file-name-extension buffer-file-name))
                  (lsp)
                  )))
  :config
  (message "web-mode config")
  (setq web-mode-indent 2)
  (setq c-basic-offset 2)
  (setq-default tab-width 8)
  (setq web-mode-markup-indent-offset web-mode-indent)
  (setq web-mode-css-indent-offset web-mode-indent)
  (setq web-mode-code-indent-offset web-mode-indent)
  (setq web-mode-style-padding 0)
  (setq web-mode-script-padding 0)
  (setq web-mode-block-padding 0)
  (setq web-mode-comment-style web-mode-indent))

(use-package haskell-mode
  :mode
  (("\\.hs$" . haskell-mode)
   ("\\.lhs$" . literate-haskell-mode)
   ("\\.cabal\\'" . haskell-cabal-mode))
  :commands
  (haskell-mode literate-haskell-mode haskell-cabal-mode)
  :hook
  haskell-indentation-mode)

(use-package dockerfile-mode
  :mode "[Dd]ockerfile")

;; elixir-mode
(use-package elixir-mode
  :config
  (alchemist-mode)
  (ac-alchemist-setup))

;; rust
(use-package rustic
  :mode ("\\.rs$" . rustic-mode)
  :commands rustic-mode
  :config
  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(use-package fsharp-mode
  :mode "\\.fs[iylx]?$")

(use-package ansi-color
  :config
  (defun display-ansi-colors ()
    (interactive)
    (ansi-color-apply-on-region (point-min) (point-max))))

(use-package csv-mode
  :mode ("\\.csv$" . csv-align-mode))

(setq ediff-split-window-function 'split-window-horizontally)

(defun projectile-path ()
  (file-relative-name buffer-file-name (projectile-project-root)))

(defun copy-projectile-path ()
  (interactive)
  (kill-new (projectile-path)))

(defun copy-projectile-line ()
  (interactive)
  (kill-new
   (concat (projectile-path) ":" (number-to-string (line-number-at-pos)))))
