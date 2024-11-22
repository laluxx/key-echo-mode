;;; key-echo-mode.el --- Display pressed keys with formatting -*- lexical-binding: t -*-
;; Author: Laluxx
;; Keywords: convenience
;; Version: 0.1

;;; Commentary:
;; A minor mode that displays pressed keys with formatting.
;; Enable:  M-x key-echo-mode
;; Disable: M-x key-echo-mode

;;; Code:
(require 'font-lock)

(defgroup key-echo nil
  "Display pressed keys with formatting."
  :group 'convenience
  :prefix "key-echo-")

(defface key-echo-namespace
  '((t :inherit default
       :foreground "white"))
  "Face for function namespace prefixes.")

(defface key-echo-command
  '((t :inherit font-lock-function-name-face))
  "Face for command name display.")

(defun key-echo--format-command-name (command-name)
  "Format COMMAND-NAME with namespace handling."
  (if (string-match "\\`\\(.+\\)/\\(.+\\)\\'" command-name)
      (concat
       (propertize (match-string 1 command-name) 'face 'key-echo-namespace)
       (propertize "/" 'face 'key-echo-namespace)
       (propertize (match-string 2 command-name) 'face 'key-echo-command))
    (propertize command-name 'face 'key-echo-command)))

(defvar key-echo-mode-map
  (make-sparse-keymap)
  "Keymap for `key-echo-mode'.")

(defun key-echo-post-command-hook ()
  "Echo the last key sequence with formatting."
  (when (and (boundp 'key-echo-mode)
             key-echo-mode
             this-command
             (not (eq this-command 'key-echo-post-command-hook)))
    (let* ((keys (this-command-keys-vector))
           (key-desc (key-description keys))
           (formatted-command (key-echo--format-command-name 
                               (symbol-name this-command)))
           (separator (propertize " → " 'face 'font-lock-comment-face)))
      (message "%s%s%s" key-desc separator formatted-command))))

(defun key-echo-mode-on ()
  "Turn on key-echo-mode."
  (add-hook 'post-command-hook #'key-echo-post-command-hook))

(defun key-echo-mode-off ()
  "Turn off key-echo-mode."
  (remove-hook 'post-command-hook #'key-echo-post-command-hook))

;;;###autoload
(define-minor-mode key-echo-mode
  "Minor mode for displaying pressed keys with formatting."
  :init-value nil
  :lighter " ⌨"
  :global t
  :keymap key-echo-mode-map
  (if key-echo-mode
      (progn
        (key-echo-mode-on)
        (message (propertize "✓ Key echo mode enabled" 'face 'success)))
    (key-echo-mode-off)
    (message (propertize "✗ Key echo mode disabled" 'face 'error))))

(provide 'key-echo-mode)
;;; key-echo-mode.el ends here
