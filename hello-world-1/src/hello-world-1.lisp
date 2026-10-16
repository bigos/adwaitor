(declaim (optimize (speed 0) (safety 3) (debug 3)))

(defpackage #:hello-world-1
  (:use #:cl)
  (:import-from :defclass-std
   :defclass/std)
  (:export
   main))

;;; (ql:quickload :hello-world-1)
(in-package #:hello-world-1)

(defvar *adw* (gir:require-namespace "Adw"))
(defvar *gio* (gir:require-namespace "Gio"))
(defvar *gtk* (gir:require-namespace "Gtk" "4.0"))

;; nget - namespace get -
;; invoke is a shortcut for funcall and nget
;; (funcall (gir:nget *gtk* "Window" 'new) 0)
;; is the same as
;; (gir:invoke (*gtk* "Window" 'new) 0)
;; there are more useful functions
;; this-of build-object-ptr cffi:foreign-pointer field property connect nget-desc

(defun main ()
  (let ((app (gir:invoke (*adw* "Application" 'new)
		         "org.adw.example"
		         (gir:nget *gio* "ApplicationFlags" :default-flags))))
    (gir:connect app "activate"
	         (lambda (app)
		   (let ((window (gir:invoke (*gtk* "ApplicationWindow" 'new) app))
                         (label (gir:invoke (*gtk* "Label" 'new) "Hello World")))

                     (gir:invoke (*gtk* "Window" 'set_title) window "Hello")
                     (gir:invoke (*gtk* "Window" 'set_default_size) window 200 200)
                     (gir:invoke (*gtk* "Window" 'set_child) window label)
		     (gir:invoke (window 'window_present)))))
    (gir:invoke (app 'run) nil)))
