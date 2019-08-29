;;; text2speech.el --- A simple Emacs text to speech API   -*- lexical-binding: t; -*-

;; Copyright (C) 2016-2019  Andreas Röhler

;; Author: Andreas Röhler <andreas.roehler@easy-emacs.de>
;; Keywords: convenience

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

;;; Commentary: Reads region loudly.

;;

;;; Code:

(defcustom text2speech-command "espeak"
  "See man-page of `espeak' which options to specify.

`espeak --voices' lists available languages"
  :type 'string
  :group 'convenience)


(defvar ar-text2speech-local-language 'english
  "Used internally when language was set resp. detected. ")

(defcustom text2speech-italian-args " -v italian-mbrola-6 -s 120 -p 50"
  "See man-page of `espeak' which options to specify.

`espeak --voices' lists available languages"
  :type 'string
  :group 'convenience)

(defcustom text2speech-german-args " -v german-mbrola-6 -s 120 -p 50"
  "See man-page of `espeak' which options to specify.

`espeak --voices' lists available languages"
  :type 'string
  :group 'convenience)

(defcustom text2speech-english-args " -v en -s 120 -p 50"
  "See man-page of `espeak' which options to specify.

`espeak --voices' lists available languages"
  :type 'string
  :group 'convenience)

(defun ar-text2speech-select-args ()
  (pcase ar-text2speech-local-language
	 (`english text2speech-english-args)
	 ;; (`french text2speech-french-args)
	 (`german text2speech-german-args)
	 ;; (`italien text2speech-italian-args)
	 ;; (`polish text2speech-polish-args)
	 ;; (`portoguese text2speech-portoguese-args)
	 ;; (`russian text2speech-russian-args)
	 ;; (`spanish text2speech-spanish-args)
	 (_ text2speech-english-args)))

(defalias 'tts 'ar-text2speech)
(defun ar-text2speech (&optional beg end)
  (interactive "r")
  (let ((beg (or beg (and (region-active-p) (region-beginning))))
	(end (or end (and (use-region-p) (region-end))))
	(text (buffer-substring-no-properties beg end))
	(text2speech-command-args (ar-text2speech-select-args)))
    (and beg end
	 (with-temp-buffer
	   (insert text)
	   (goto-char (point-min))
	   (while (search-forward "\n" nil t 1)
	     (replace-match " "))
	   (shell-command-on-region (point-min) (point-max)
				    ;; "espeak -v english-mb-en1 -s 1"
				    ;; "espeak -s 100 -p 50"
				    (concat text2speech-command text2speech-command-args))))))

(provide 'text2speech)
;;; text2speech.el ends here
