;;; rails-ruby.el --- provide features for ruby-mode

;; Copyright (C) 2006 Dmitry Galinsky <dima dot exe at gmail dot com>

;; Authors: Dmitry Galinsky <dima dot exe at gmail dot com>

;; Keywords: ruby rails languages oop
;; $URL: svn://rubyforge.org/var/svn/emacs-rails/trunk/rails-ruby.el $
;; $Id: rails-ruby.el 153 2007-03-31 20:30:51Z dimaexe $

;;; License

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

;;; Code:

(eval-when-compile
  (require 'inf-ruby))

;; setup align for ruby-mode
(require 'align)

(defconst align-ruby-modes '(ruby-mode)
  "align-perl-modes is a variable defined in `align.el'.")

(defconst ruby-align-rules-list
  '((ruby-comma-delimiter
     (regexp . ",\\(\\s-*\\)[^/ \t\n]")
     (modes  . align-ruby-modes)
     (repeat . t))
    (ruby-symbol-after-func
     (regexp . "^\\s-*\\w+\\(\\s-+\\):\\w+")
     (modes  . align-ruby-modes)))
  "Alignment rules specific to the ruby mode.
See the variable `align-rules-list' for more details.")

(add-to-list 'align-perl-modes 'ruby-mode)
(add-to-list 'align-dq-string-modes 'ruby-mode)
(add-to-list 'align-sq-string-modes 'ruby-mode)
(add-to-list 'align-open-comment-modes 'ruby-mode)
(dolist (it ruby-align-rules-list)
  (add-to-list 'align-rules-list it))

(defun ruby-newline-and-indent ()
  (interactive)
  (newline)
  (ruby-indent-command))

(defun ruby-toggle-string<>simbol ()
  "Easy to switch between strings and symbols."
  (interactive)
  (let ((initial-pos (point)))
    (save-excursion
      (when (looking-at "[\"']") ;; skip beggining quote
        (goto-char (+ (point) 1))
        (unless (looking-at "\\w")
          (goto-char (- (point) 1))))
      (let* ((point (point))
             (start (skip-syntax-backward "w"))
             (end (skip-syntax-forward "w"))
             (end (+ point start end))
             (start (+ point start))
             (start-quote (- start 1))
             (end-quote (+ end 1))
             (quoted-str (buffer-substring-no-properties start-quote end-quote))
             (symbol-str (buffer-substring-no-properties start end)))
        (cond
         ((or (string-match "^\"\\w+\"$" quoted-str)
              (string-match "^\'\\w+\'$" quoted-str))
          (setq quoted-str (substring quoted-str 1 (- (length quoted-str) 1)))
          (kill-region start-quote end-quote)
          (goto-char start-quote)
          (insert (concat ":" quoted-str)))
         ((string-match "^\:\\w+$" symbol-str)
          (setq symbol-str (substring symbol-str 1))
          (kill-region start end)
          (goto-char start)
          (insert (format "'%s'" symbol-str))))))
    (goto-char initial-pos)))

(defun run-ruby-in-buffer (cmd buf)
  "Run CMD as a ruby process in BUF if BUF does not exist."
  (let ((abuf (concat "*" buf "*")))
    (when (not (comint-check-proc abuf))
      (set-buffer (make-comint buf rails-ruby-command nil cmd)))
    (inferior-ruby-mode)
    (make-local-variable 'inferior-ruby-first-prompt-pattern)
    (make-local-variable 'inferior-ruby-prompt-pattern)
    (setq inferior-ruby-first-prompt-pattern "^>> "
          inferior-ruby-prompt-pattern "^>> ")
    (pop-to-buffer abuf)))

(provide 'rails-ruby)