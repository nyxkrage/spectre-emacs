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
;; Package-Requires: ((emacs "25.1"))
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
  "Spectre Password Manager options"
  :group 'conf)

(defcustom spectre-master-password nil
  "The master password used when generating passwords"
  :type 'string
  :group 'spectre)
(defcustom spectre-full-name (if (boundp 'user-full-name) user-full-name nil)
  "The name used when generating passwords defaults to `user-full-name`"
  :type 'string
  :group 'spectre)

(defun spectre-password (site)
  (interactive "sEnter the site you wish to generate a password for: ")
  (unless spectre-full-name (setq spectre-master-password (read-string "Enter your full name: ")))
  (unless spectre-master-password (setq spectre-master-password (read-passwd "Enter your master password: ")))
  (kill-new (spectre-make-password spectre-full-name spectre-master-password site)))

(provide 'spectre)
;;; spectre.el ends here
