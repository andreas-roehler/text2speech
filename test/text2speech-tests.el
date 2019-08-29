;;; text2speech-tests.el --- text2speech tests       -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Andreas Röhler

;; Author: Andreas Röhler <andreas.roehler@easy-emacs.de>
;; Keywords: lisp

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(defvar ar-switch-p nil
  "Switch into test-buffer.")
;; (setq ar-switch-p t)

(defcustom ar-switch-p nil
  ""
  :type 'boolean
  :group 'werkstatt)

(defun ar-toggle-switch-p ()
  "Toggle `ar-switch-p'. "
  (interactive)
  (setq ar-switch-p (not ar-switch-p))
  (message "ar-switch-p: %s"  ar-switch-p))

(defmacro ar-test-with-elisp-buffer (contents &rest body)
  "Create temp buffer in `emacs-lisp-mode' inserting CONTENTS.
BODY is code to be executed within the temp buffer.  Point is
 at the end of buffer."
  (declare (indent 1) (debug t))
  `(with-temp-buffer
     (let (hs-minor-mode)
       (insert ,contents)
       (emacs-lisp-mode)
       (when ar-switch-p
	 (switch-to-buffer (current-buffer))
	 (font-lock-fontify-region (point-min) (point-max)))
       ,@body)))

(defmacro ar-test-with-elisp-buffer-point-min (contents &rest body)
  "Create temp buffer inserting CONTENTS.
BODY is code to be executed within the temp buffer.  Point is
 at the end of buffer."
  (declare (indent 2) (debug t))
  `(with-temp-buffer
     (let (hs-minor-mode)
       (insert ,contents)
       (emacs-lisp-mode)
       (goto-char (point-min))
       (when ar-switch-p
	 (switch-to-buffer (current-buffer)))
       (font-lock-fontify-region (point-min) (point-max))
       ,@body)))

(ert-deftest ar-text2speech-keep-current-list ()
  (ar-test-with-elisp-buffer
  "(defun foo1 (&optional beg end))"
  (push-mark)
  (search-backward "&")
  (ar-text2speech (point) (mark))
  (should-not (eobp))
  ))

(defun foo1 (&optional beg end))


(provide 'text2speech-tests)
;;; text2speech-tests.el ends here
