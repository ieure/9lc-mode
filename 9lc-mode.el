;;; 9lc-mode.el --- Major mode for editing Fluke 9000 scripts

;; Copyright (C) 2014, 2015, 2016, 2018  Ian Eure

;; Author: Ian Eure <ian.eure@gmail.com>
;; Version: 0.6
;; Keywords: extensions, languages

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

;; This is a major mode for editing Fluke 9000 scripts.

;;; History:

;;  2014-2017
;;   Initial versions.

;; 2018-01-21
;;   Renamed to 9lc-mode (from flub-mode).
;;   Rewrote to be based on prog-mode instead of asm-mode.
;;   Implemented correct indentation behavior.
;;   Improved font-lock behavior.

;;; Code:

(defconst 9lc-keywords
  (concat "\\b"
          (regexp-opt '("active"
                        "address"
                        "and"
                        "assign"
                        "atog"
                        "auto\\(?:\\s-+ test\\)?"
                        "aux"
                        "bad"
                        "beep"
                        "binary"
                        "bit"
                        "bits"
                        "bts"
                        "bus\\(?:\\s-+ test\\)?"
                        "bytes"
                        "control"
                        "cpl"
                        "ctl"
                        "data"
                        "dec"
                        "declarations"
                        "dpy"
                        "dtog"
                        "enable"
                        "err"
                        "error"
                        "errors"
                        "ex"
                        "exercise\\s-+errors"
                        "execute"
                        "force"
                        "free"
                        "goto"
                        "if"
                        "illegal"
                        "inc"
                        "include"
                        "information"
                        "interrupt"
                        "io\\(?:\\s-+ test\\)?"
                        "label"
                        "learn"
                        "line"
                        "linesize"
                        "long"
                        "loop"
                        "newline"
                        "on"
                        "or"
                        "por"
                        "power"
                        "probe"
                        "program"
                        "ram short"
                        "ram long"
                        "ramp"
                        "rd"
                        "read"
                        "reg"
                        "rept"
                        "rom"
                        "rom test"
                        "run uut"
                        "setup"
                        "shl"
                        "short"
                        "shr"
                        "sig"
                        "space"
                        "stall"
                        "stop"
                        "sts"
                        "supply"
                        "sync"
                        "timeout"
                        "to"
                        "transition"
                        "trap"
                        "unstall"
                        "walk"
                        "wr"
                        "write"))
          "\\b")

  "9LC language keywords.")

(defconst 9lc-mode-font-lock-keywords
  `(
    ("\\bREG\\s-*[A-F0-9]\\b" . font-lock-variable-name-face)

    ("\\b\\(yes\\|no\\)\\b" . font-lock-constant-face)
    ("@" . font-lock-constant-face)

    ("\\binclude\\b" . font-lock-preprocessor-face)

    ;; Labels
    ("^\\s-*\\([A-Z0-9]+\\):" . font-lock-function-name-face)

    ("\\bprogram\\s-+\\([0-9A-Z]+\\)"
     (1 font-lock-function-name-face))

    ("\\(?:ex\\|execute\\)\\s-+\\([0-9A-Z]+\\)"
     (1 font-lock-function-name-face))

    ("\\(?:goto\\)\\s-+\\([0-9A-Z]+\\)"
     (1 font-lock-function-name-face))

    ("\\bdpy[- ]\\([a-z0-9 _=@#;<>%\"\.\$\?\\\\+-]+\\)"
     (1 font-lock-string-face))

    (,9lc-keywords
     . font-lock-keyword-face)
    ))

(defvar 9lc-mode-syntax-table
  (let ((table (make-syntax-table)))
    ;; A `!' is the start of a comment
    (modify-syntax-entry ?! "<" table)
    ;; The comment extends to the end of the line the `!' appears on.
    (modify-syntax-entry ?\n ">" table)
    table))

;; Indentation rules:
;;
;; INCLUDE, SETUP, PROGRAM, and labels are all aligned to 0.
;; All other statements are indented one level.

(defun 9lc-mode-indent ()
  "Indent the current line."
  (interactive)
  (indent-line-to
   (save-excursion
     (goto-char (line-beginning-position))
     (if (looking-at "^\\s-*\\(program\\|setup\\|declarations\\|address space information\\|include\\|[a-z0-9]+:\\|!\\)")
         0
       tab-width))))

;;;###autoload
(define-derived-mode 9lc-mode prog-mode "9LC"
  "Major mode for editing Fluke 9000 source."
  (setq tab-width 2)
  (setq tab-stop-list '(2 0))
  (setq indent-line-function #'9lc-mode-indent)
  (setq tab-always-indent t)

  (set-syntax-table 9lc-mode-syntax-table)
  (setq comment-use-syntax t)
  (setq fill-prefix nil)

  (set (make-local-variable 'font-lock-defaults)
       '(9lc-mode-font-lock-keywords nil t)))

;;;###autoload
(add-to-list 'auto-mode-alist
             (cons "\\.9lc\\'" '9lc-mode))

(provide '9lc-mode)
;;; 9lc-mode.el ends here
