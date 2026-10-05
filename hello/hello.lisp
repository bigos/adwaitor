(declaim (optimize (speed 1) (safety 3) (debug 3)))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (ql:quickload '(:alexandria :defclass-std)))

(defpackage #:hello
  (:use #:cl)
  (:export main))

;; (ql:quickload :hello)
(in-package #:hello)
;;; (main)

(defun msg ()
  "This is hello")

(defun main ()
  (format t "~A~%" (msg)))
