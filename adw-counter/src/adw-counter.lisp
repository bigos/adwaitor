(declaim (optimize (speed 0) (safety 3) (debug 3)))

;;; (ql:quickload :adw-counter)
(in-package #:adw-counter)
;;; (main)

(defun simple-counter ()
  ;; not much progress
  )

;; https://gnome.pages.gitlab.gnome.org/libadwaita/doc/main/initialization.html
(defun main ()
  (format t "Beginning of the counter")
  (unless (adw:initialized-p)
    (adw:init)
    (simple-counter)))
