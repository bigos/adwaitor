(declaim (optimize (speed 0) (safety 3) (debug 3)))

;;; (ql:quickload :adw-counter)
(in-package #:adw-counter)
;;; (main)

(defun main-window-content (win)
  (gtk4:widget-add-css-class "devel")
  (setf (gtk4:widget-size-request window) '(400 600))
  (let ((box (gtk4:make-box :orientation gtk4:+orientation-vertical+
                            :spacing 0)))
    (setf (adw:window-content win) box)
    (let ((header-bar (adw:make-header-bar)))
      (setf (adw:header-bar-title-widget header-bar)
            (adw:make-window-title :title "Adwaita Counter"
                                   :subtitle "the first"))
      (gtk4:box-append header-bar)


      )
    )

  ;; todo



(unless (gtk4:widget-visible-p win) (gtk4:window-present win)))

(defun simple-counter ()
  ;; not much progress
  (let ((app (gtk4:make-application :application-id "adwaitor.counter" :flags 0)))
    (gtk4:connect app "activate"
                  (lambda (app2)
                    (let ((win (adw:make-application-window :app app2)))
                      (main-window-content win)
                      (gtk4:connect win "destroy"
                               (lambda (win-z)
                                 (setf win-z nil)))
                      )))
    (gtk4:application-run app nil)))

;; https://gnome.pages.gitlab.gnome.org/libadwaita/doc/main/initialization.html
(defun main ()
  (format t "Beginning of the counter")
  (unless (adw:initialized-p)
    (adw:init)
    (simple-counter)))
