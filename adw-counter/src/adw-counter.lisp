(declaim (optimize (speed 0) (safety 2) (debug 3)))

;;; (ql:quickload :adw-counter)
(in-package #:adw-counter)
;;; (main)

(defparameter *application* nil)
(defparameter  *app-window* nil)

(defparameter  *counter* 0)
(defparameter *lab* nil)

(defun main-window-content (window)
  (declare (ignorable window))
  (let ((expression nil))
    ;; (gtk4:WIDGET-ADD-CSS-CLASS WINDOW "devel")
    (setf (gtk4:widget-size-request window) '(400 200))
    (let ((box (gtk4:make-box :orientation gtk4:+orientation-vertical+ :spacing 0)))
      (setf (adw:window-content window) box)
      (let ((header-bar (adw:make-header-bar)))
        (setf (adw:header-bar-title-widget header-bar)
              (adw:make-window-title :title (format nil "~A will be counter" (lisp-implementation-type))
                                     :subtitle
                                     ;; (LISP-IMPLEMENTATION-VERSION)
                                     nil))
        (gtk4:box-append box header-bar))

      (let ((box2
              (gtk4:make-box :orientation gtk4:+orientation-horizontal+ :spacing
                             0)))
        (setf (gtk4:widget-hexpand-p box2) t
              (gtk4:widget-halign box2) gtk4:+align-fill+)

        (let ((button (gtk4:make-button :label "Exit")))
          (setf (gtk4:widget-css-classes button) '("pill")
                (gtk4:widget-margin-all button) 10
                (gtk4:widget-hexpand-p button) t)
          (gtk4:connect button "clicked"
                        (lambda (button)
                          (declare (ignore button))
                          (gtk4:window-destroy window)))
          (gtk4:box-append box2 button))
        (let ((button (gtk4:make-button :label "Eval -")))
          (setf (gtk4:widget-css-classes button)
                '("suggested-action" "pill")
                (gtk4:widget-margin-all button) 10
                (gtk4:widget-hexpand-p button) t)
          (gtk4:connect button "clicked" (lambda (button)
                                           (decf *counter*)
                                           (setf (gtk4:label-text *lab*) (format nil "~s" *counter*))
                                           (warn "clicked -")))
          (gtk4:box-append box2 button))
        (let ((button (gtk4:make-button :label "Eval +")))
          (setf (gtk4:widget-css-classes button)
                '("suggested-action" "pill")
                (gtk4:widget-margin-all button) 10
                (gtk4:widget-hexpand-p button) t)
          (gtk4:connect button "clicked" (lambda (button)
                                           (incf *counter*)
                                           (setf (gtk4:label-text *lab*) (format nil "~s" *counter*))
                                           (warn "clicked +")))
          (gtk4:box-append box2 button))
        (gtk4:box-append box box2))
      (let ((box3
              (gtk4:make-box :orientation gtk4:+orientation-horizontal+ :spacing
                             0)))
        (setf (gtk4:widget-hexpand-p box3) t
              (gtk4:widget-halign box3) gtk4:+align-fill+)

        (let ((labyy (gtk4:make-label :str "Press counter buttons")))
          (setf
                (gtk4:widget-margin-all labyy) 10
                (gtk4:widget-hexpand-p labyy) t)
          (setf *lab* labyy)

          (gtk4:box-append box3 labyy))
        (gtk4:box-append box box3)))

    (unless (gtk4:widget-visible-p window) (gtk4:window-present window))))

(defun window-main (&optional gtk4::argv)
  (let ((gtk4::app
          (gtk4:make-application :application-id
                            "org.bohonghuang.libadwaita-example.simple-repl"
                            :flags 0)))
    (gtk4:connect gtk4::app "activate"
             (lambda (gtk4::app)
               (declare (ignore gtk4::app))
               (let ((gtk4::win
                       (setf *app-window*
                             (adw:make-application-window :app
                                                          *application*))))
                 (main-window-content gtk4::win)

                 (gtk4:connect gtk4::win "destroy"
                          (lambda (gtk4::win)
                            (declare (ignore gtk4::win))
                            (setf *app-window*
                                  nil))))))
    (gtk4:application-run gtk4::app gtk4::argv)))

(defun main ()
  (unless (adw:initialized-p)
    (adw:init))
  (window-main)
  (gtk4:idle-add (lambda () (main-window-content *app-window*))))
