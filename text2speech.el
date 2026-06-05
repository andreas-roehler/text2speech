;;; text2speech.el --- A simple Emacs text to speech API   -*- lexical-binding: t; -*-

;; Copyright (C) 2016-2026  Andreas Röhler

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

;; Requires ‘espeak’

;;; Code:

(defcustom text2speech-command "espeak"
  "See man-page of `espeak' which options to specify.

`espeak --voices' lists available languages"
  :type 'string
  :group 'convenience)


(defvar ar-detect-language-check-max 5000)

(defvar ar-ascii-related-languages
  (list
   'french
   'german
   'italien
   'polish
   'portoguese
   'spanish))

;; (defun german-maybe ()
;;   (save-excursion
;;     (goto-char (point-min))
;;   (let ((aumlmatch (search-forward "ä" nil t 1))
;; 	(Aumlmatch (search-forward "Ä" nil t 1))
;; 	(uumlmatch (search-forward "ü" nil t 1))
;; 	(Uumlmatch (search-forward "Ü" nil t 1))
;; 	(oumlmatch (search-forward "ö" nil t 1))
;; 	(Oumlmatch (search-forward "Ö" nil t 1))
;; 	(szmatch (search-forward "ß" nil t 1)))
;;     (when
;; 	(or aumlmatch Aumlmatch uumlmatch Uumlmatch oumlmatch Oumlmatch szmatch)
;;       'german))))

;; italienisch (249 233 236 232 224 242)

(defvar ar-italien-chars '(249 233 236 232 224 242))

(defvar ar-german-chars '(196 220 214 223 228 252 246))

(defun ar-detect-ascii-related (lang count)
  (dolist (elt (pcase
		   lang
		 ('italien ar-italien-chars)
		 ('german ar-german-chars)))
    (goto-char (point-min))
    (when (and
	   (search-forward (char-to-string elt) nil t 1)
	   ;; range of ascii-alpha
	   (or (and (< 64 (char-after)) (< (char-after) 128))
	       (progn (goto-char (match-beginning 0))
		      (and (< 64 (char-after))(< (char-before) 128)))))
      (setq count (1+ count))))
  count)

(defvar ar-ascii-tolerated-chars (list ?↑ ?→))

(defun ar-ascii-p ()
  "Return `t' if in mostly ascii-buffer. "
  (interactive)
  (let ((count 0.0))
    ;; (goto-char (point-min))
    (while
	;; doesn't work because of ligatures: tradeoﬀ
	(re-search-forward "[^[:ascii:]]" nil 'move 1)
      (unless
	  ;; (eq (char-before) ?→)
	  (member (char-before) ar-ascii-tolerated-chars)
	(setq count (1+ count))))
    (< (/ count (point-max)) 0.003)))

(defun ar-detect-language-intern (lang)
  ;; narrow the buffer to half, ignore multi-lang references at the
  ;; end maybe
  (save-excursion
    ;; (save-restriction
    ;;   (unless (bobp)
    ;; 	(backward-paragraph))
    ;;   (narrow-to-region (point) (min (point-max) ar-detect-language-check-max))
    ;;   ;; (narrow-to-region (point-min) (/ (point-max) 2))
    (let ((count 0))
      (if (member lang ar-ascii-related-languages)
	  (ar-detect-ascii-related lang count)
	(pcase lang ('english (ar-ascii-p)))))))

(defun ar-english-p ()
  "Return `t', if text in buffer or region is english. "
  (interactive)
  (ar-detect-language-intern 'english))

(defun ar-wort-la-italienisch ()
  (interactive)
  (let ((count 0.0))
    (goto-char (point-min))
    (while (re-search-forward "\\bla\\b" nil t 1)
      (setq count (1+ count)))
    (/ count (point-max))))

(defvar russian-chars (list ?я ?щ ?и ?з ?д ?л ?ь ?т ?в ?р ?г ?п ?ф ?ю ?ч ?н))
;; (setq russian-chars (list ?я ?щ ?и ?з ?д ?л ?ь ?т ?в ?р ?г ?п ?ф ?ю ?ч ?н))

(defun ar-russian-p ()
  (interactive)
  (let ((count 0))
    (dolist (elt russian-chars)
      (goto-char (point-min))
      (when (search-forward (char-to-string elt) nil t 1)
	(setq count (1+ count))))
    (< 12 count)))

(defun ar-italien-p ()
  "Return `t', if text in buffer or region is italien. "
  (interactive)
  (or (<  0.0009 (ar-wort-la-italienisch))
      (< 3 (ar-detect-language-intern 'italien))))

(defun ar-russian-p ()
  "Return `t', if text in buffer or region is russian. "
  (interactive)
  (or (<  0.0009 (ar-wort-la-italienisch))
      (< 3 (ar-detect-language-intern 'russian))))

(defun ar-german-p ()
  "Return `t', if text in buffer or region is german. "
  (interactive)
  (< 3 (ar-detect-language-intern 'german)))

(defun ar-detect-language ()
  (cond
   ((ar-english-p)
    'english)
   ;; ((ar-french-p)
   ;; 'french)
   ((ar-german-p)
    'german)
   ((ar-italien-p)
    'italien)
   ;; ((ar-polish-p)
   ;; 'polish)
   ;; ((ar-portoguese-p)
   ;; 'portoguese)
   ((ar-russian-p)
    'russian)
   ;; ((ar-spanish-p)
   ;; 'spanish)
   ))

(defvar ar-text2speech-which-language 'english
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
  (pcase ar-text2speech-which-language
	 (`english text2speech-english-args)
	 ;; (`french text2speech-french-args)
	 (`german text2speech-german-args)
	 (`italien text2speech-italian-args)
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

(defun read-by-sentence ()
  "Speaks out sentence at point.

At code any symbol"
  (interactive)
  (skip-chars-forward " \t\r\n\f")
  (push-mark)
  (let* ((sentence-end (or sentence-end "[.?!]* "))
         (end-raw (save-excursion (skip-chars-forward "^ \t\r\n\f") (point)))
         (end (max (re-search-forward sentence-end) end-raw)))
    (ar-text2speech (mark) end)
    (goto-char end)))

(provide 'text2speech)
;;; text2speech.el ends here
