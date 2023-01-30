;;; spectre.el --- Spectre Password Manager -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2023 Carsten Kragelund
;;
;; Author: Carsten Kragelund <carsten@kragelund.me>
;; Maintainer: Carsten Kragelund <carsten@kragelund.me>
;; Created: January 22, 2023
;; Modified: January 22, 2023
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex tools unix vc wp
;; Homepage: https://github.com/carsten/spectre
;; Package-Requires: ((emacs "26.1"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:

(require 'spectre-module)

(defgroup spectre nil
  "Spectre Password Manager options."
  :group 'conf)

(defcustom spectre-master-password ""
  "The master password used when generating passwords."
  :type 'string
  :group 'spectre)
(defcustom spectre-full-name (if (boundp 'user-full-name) user-full-name "")
  "The name used when generating passwords defaults to `user-full-name`."
  :type 'string
  :group 'spectre)

(defvar spectre-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map widget-keymap)
    map)
  "Spectre UI key map.")

(define-derived-mode spectre-mode
  fundamental-mode "Spectre"
  "Major mode for The Spectre Password Manager.")

(defun spectre ()
  "Popup the Spectre UI Buffer."
  (interactive)
  (let ((buf "*doom:spectre-popup:main*"))
  (spectre-buffer__internal buf nil nil "" nil)
  (if-let (win (get-buffer-window buf))
      (delete-window win)
    (pop-to-buffer buf))))

(defun spectre-here ()
  "Switch to the Spectre UI Buffer."
  (interactive)
  (let ((buf "*spectre*"))
    (spectre-buffer__internal buf nil nil "" nil)
    (switch-to-buffer buf)))

(require 'widget)
(require 'wid-edit)

(defvar spectre-debounce-timer__internal nil)

(defun spectre-buffer__internal (buf &optional show-password show-master-password site-name point)
  "BUF SHOW-PASSWORD SHOW-MASTER-PASSWORD SITE-NAME POINT."
  (get-buffer-create buf)
  (set-buffer buf)
  (spectre-mode)
  (erase-buffer)
  (remove-overlays)
  (widget-insert "Spectre Password Manager\n\n")
  (let (password-widget
        master-password-widget
        name-widget
        site-widget)
    (setq name-widget
          (widget-create 'editable-field
                         :format "  Full Name: %v \n"
                         :size 30
                         :value spectre-full-name
                         :notify (lambda (widget &rest _) (setq spectre-full-name (widget-value widget)))))
    (setq master-password-widget
          (widget-create 'editable-field
                         :format "  Master Password: %v \n"
                         :size 30
                         :value spectre-master-password
                         :secret (and (not show-master-password) ?*)
                         :notify (lambda (widget &rest _) (setq spectre-master-password (widget-value widget)))))
    (widget-create 'push-button
                   :format "    %[%t%] \n\n"
                   :value (concat (if show-master-password "Hide" "Show") " Master Password")
                   :notify (lambda (&rest _)
                             (cancel-timer spectre-debounce-timer__internal)
                             (spectre-buffer__internal buf show-password (not show-master-password) site-name (point))))
    (setq site-widget
          (widget-create 'editable-field
                         :format "  Site: %v \n"
                         :size 30
                         :value (or site-name "")
                         :notify (lambda (widget &rest _)
                                   (setq site-name (widget-value widget))
                                   (spectre-render-password__internal password-widget site-name show-password))))
    (setq password-widget
          (widget-create 'item
                         :value (if show-password (spectre-password__internal site-name)
                                  (make-string (length (spectre-password__internal site-name)) ?*))))
    (widget-create 'push-button
                   :format "    %[%t%] "
                   :value "Copy Password"
                   :notify (lambda (&rest _)
                             (kill-new (spectre-make-password spectre-full-name spectre-master-password site-name))))
    (widget-create 'push-button
                   :format " %[%t%] \n\n"
                   :value (concat (if show-password "Hide" "Show") " Password")
                   :notify (lambda (&rest _)
                             (cancel-timer spectre-debounce-timer__internal)
                             (spectre-buffer__internal buf (not show-password) show-master-password site-name (point))))
    (widget-setup)
    (use-local-map widget-keymap)
    (unless spectre-full-name
      (setq point (widget-field-start name-widget)))
    (unless spectre-master-password
      (setq point (widget-field-start master-password-widget)))
    (goto-char (or point (widget-field-start site-widget)))))


(defun spectre-render-password__internal (widget site show)
  "WIDGET SITE SHOW."
  (if spectre-debounce-timer__internal
      (cancel-timer spectre-debounce-timer__internal))
  (setq spectre-debounce-timer__internal (run-with-timer 0.1 nil
                                                         (lambda ()
                                                           (widget-value-set widget
                                                                             (if show (spectre-password__internal site)
                                                                               (make-string (length (spectre-password__internal site)) ?*)))))))

(defun spectre-password__internal (site)
  "SITE."
  (let ((password (spectre-make-password spectre-full-name spectre-master-password site)))
    (if (eq password 0)
        ""
      password)))

(defun spectre-ask-information ()
  "Prompt for name and master password if they aren't set."
  (interactive)
  (unless spectre-full-name (setq spectre-master-password (read-string "Enter your full name: ")))
  (unless spectre-master-password (setq spectre-master-password (read-passwd "Enter your master password: "))))

(defun spectre-password (site)
  "Generate password for site SITE and put it into the 'kill-ring'."
  (interactive "sEnter the site you wish to generate a password for: ")
  (kill-new (spectre-make-password spectre-full-name spectre-master-password site)))

(provide 'spectre)
;;; spectre.el ends here
