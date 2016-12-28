;;; text2speech.el --- A simple Emacs text to speech API   -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Andreas Röhler

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

;;; Commentary:

;;

;;; Code:

(require 'thingatpt-utils-core)
(require 'detect-language)

(defvar ar-text2speech-local-language nil
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

(defcustom text2speech-english-args " -v english-mb-en1 -s 120 -p 50"
  "See man-page of `espeak' which options to specify.

`espeak --voices' lists available languages"
  :type 'string
  :group 'convenience)

(defcustom text2speech-command "espeak"
  "See man-page of `espeak' which options to specify.

`espeak --voices' lists available languages"
  :type 'string
  :group 'convenience)

(defcustom text2speech-sentence-command (quote (bounds-of-thing-at-point 'sentence))
  "Provide an alternative to built-in `sentence-at-point'.

Note: `ar-sentence-at-point-atpt' requires `thing-at-point-utils' and subroutines from `https'://github.com/andreas-roehler/werkstatt "
  :type '(choice (const :tag "ar-bounds-of-sentence-atpt" (ar-bounds-of-sentence-atpt))
                 (const :tag "sentence-at-point" (bounds-of-thing-at-point 'sentence)))
  :tag "Which sentence-at-point function"
  :group 'convenience)

(defcustom ar-sentence-forward-command 'forward-sentence
  "Provide an alternative to built-in `forward-sentence'.

Note: `ar-sentence-forward-atpt' requires `thing-at-point-utils' and subroutines from `https'://github.com/andreas-roehler/werkstatt "
  :type '(choice
	  (const :tag "ar-sentence-forward-atpt" ar-sentence-forward-atpt)
	  (const :tag "forward-sentence" forward-sentence))
  :tag "forward-sentence"
  :group 'convenience)

(defcustom ar--t2s-skip-navigation-p t
  "If titles and navigation stuff should be skipped.

Default is t"

  :type 'boolean
  :group 'convenience)

(defun ar--t2s-skip-navigation ()
  "Leave out some stuff at head of page maybe. "
  (let ((limit (save-excursion (forward-paragraph 2)(point))))
    (when (re-search-forward "^[[:alpha:]]+ Wikipedia" limit t 1)
      (forward-paragraph)
      (skip-chars-forward " \t\r\n\f"))))

(defun text2speech--intern (beg end text2speech-command text2speech-command-args)
  (let ((text (buffer-substring-no-properties beg end)))
    (with-temp-buffer
      (insert text)
      (goto-char (point-min))
      (while (search-forward "\n" nil t 1)
	(replace-match " "))
      (shell-command-on-region (point-min) (point-max) (concat text2speech-command text2speech-command-args)))))

(defun text2speech--find-bounds (thing)
  (let* ((bounds (cond ((eq thing 'sentence)
			(ar-bounds-of-sentence-atpt))))
	 (beg (cond (bounds (car bounds))
		    ((use-region-p)
		     (region-beginning))
		    (t (line-beginning-position))))
	 (end (cond (bounds (cdr bounds))
		    ((use-region-p)
		     (copy-marker (region-end)))
		    (t (line-end-position)))))
    (list beg end)))

(defun text2speech--do (&optional thing beg end text2speech-command-args)
  "Determine the bounds unless given. "
  (if (and beg end)
      (progn
	(text2speech--intern beg end text2speech-command text2speech-command-args)
	(list beg end))
    (let ((bounds (text2speech--find-bounds thing)))
      (text2speech--intern (car bounds) (cadr bounds) text2speech-command text2speech-command-args)
      bounds)))

(defun text2speech--forward-base (text2speech-command-args form &optional beg end)
  (let ((orig (point))
	(bounds (text2speech--do form beg end text2speech-command-args)))
    ;; go to the end of form, so next forward starts from
    ;; (when (and (eq (point) orig)(not (eobp))
    ;; 	       (pcase form ('sentence
    ;; 			    (funcall ar-sentence-forward-command))
    ;; 		      (_ (skip-chars-forward " \t\r\n\f"))))
    ;;   (text2speech--forward-base text2speech-command-args form beg end))
    (ignore-errors (goto-char (cadr bounds)))
    (pcase form ('sentence
		 (funcall ar-sentence-forward-command))
	   (_ (forward-line)))
    bounds))

(defun text2speech-sentence-and-forward-english ()
  "Read the sentence w/ english voice and move to next. "
  (interactive)
  (text2speech--forward-base text2speech-english-args 'sentence))

(defun text2speech-sentence-and-forward-german ()
  "Read the sentence w/ german voice and move to next. "
  (interactive)
  (text2speech--forward-base text2speech-german-args 'sentence))

(defun text2speech-sentence-and-forward-italian ()
  "Read the sentence w/ italian voice and move to next. "
  (interactive)
  (text2speech--forward-base text2speech-italian-args 'sentence))

(defun text2speech (&optional arg)
  "Run a text-to-speech API.

Selects language according to optional ARG.
Fallback uses `detect-language.el' "
  (interactive "P")
  ;; (when ar--t2s-skip-navigation-p
  ;; (ar--t2s-skip-navigation))
  (pcase (prefix-numeric-value arg)
    (4 (text2speech-sentence-and-forward-german))
    (2 (text2speech-sentence-and-forward-italian))
    (3 (text2speech-sentence-and-forward-english))
    (_ (unless ar-text2speech-local-language
	 (when (functionp 'ar-detect-language)(setq ar-text2speech-local-language (ar-detect-language))))
       (pcase ar-text2speech-local-language
	 ('english (text2speech-sentence-and-forward-english))
	 ('french (text2speech-sentence-and-forward-french))
	 ('german (text2speech-sentence-and-forward-german))
	 ('italien (text2speech-sentence-and-forward-italian))
	 ('polish (text2speech-sentence-and-forward-polish))
	 ('portoguese (text2speech-sentence-and-forward-portoguese))
	 ('russian (text2speech-sentence-and-forward-russian))
	 ('spanish (text2speech-sentence-and-forward-spanish))
	 (_ (message "%s" "Was detect-language.el loaded?"))))))

(provide 'text2speech)
;;; text2speech.el ends here
