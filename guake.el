;;; guake.el --- Interact with Guake via DBus -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Jürgen Hötzel

;; Author: Jürgen Hötzel <juergen.hoetzel@hr.de>
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
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; ;; Provides commands to interact with Guake http://guake-project.org/

;;; Code:


(require 'dbus)

;; helper
(defun guake--call-rc (&rest args)
  (apply #'dbus-call-method
	 :session "org.guake3.RemoteControl"
	 "/org/guake3/RemoteControl"
	 "org.guake3.RemoteControl"
	 args))

(defun guake-get-tab-count ()
  (guake--call-rc "get_tab_count"))

(defun guake-get-tab-names ()
  (mapcar (lambda (index)
	      (guake--call-rc
	       "get_tab_name" :int32 index))
	    (number-sequence 0 (1- (guake-get-tab-count)))))

(defun guake-show ()
  (guake--call-rc "show"))

(defun guake-select-tab (index)
  (guake--call-rc "select_tab" :int32 index))

(defun guake-switch-to-tab (name)
  "Switch to tab NAME and show Guake terminal."
  (interactive
   (list
    (insert
     (let* ((choices (mapcar (lambda (index)
			      (let ((name (guake--call-rc "get_tab_name" :int32 index)))
				   (prog1
				       name
				     (put-text-property 0 1 :_guake index name))))
			     (number-sequence 0 (1- (guake-get-tab-count)))))
	    (index (get-text-property 0 :_guake (completing-read "Tab: " choices))))
       (guake-select-tab index)
       (guake-show))))))

(provide 'guake)






