(declaim (optimize (speed 0) (safety 3) (debug 3)))

;;; (ql:quickload :adw-counter)
(in-package #:adw-counter)
;;; (main)

(defparameter *application* nil)
(defparameter  *app-window* nil)

(defun main-window-content (window)
  (declare (ignorable window))
  (let ((expression nil))
    ;; (gtk4:WIDGET-ADD-CSS-CLASS WINDOW "devel")
    (setf (gtk4:widget-size-request window) '(400 600))
    (let ((box (gtk4:make-box :orientation gtk4:+orientation-vertical+ :spacing 0)))
      (setf (adw:window-content window) box)
      (let ((header-bar (adw:make-header-bar)))
        (setf (adw:header-bar-title-widget header-bar)
              (adw:make-window-title :title (format nil "~A will be counter" (lisp-implementation-type))
                                     :subtitle
                                     ;; (LISP-IMPLEMENTATION-VERSION)
                                     nil))
        (gtk4:box-append box header-bar))
      (let ((carousel (adw:make-carousel)))
        (setf (gtk4:widget-hexpand-p carousel) t
              (gtk4:widget-vexpand-p carousel) t
              (adw:carousel-interactive-p carousel) t)
        (let ((page (adw:make-status-page)))
          (setf (gtk4:widget-hexpand-p page) t
                (gtk4:widget-vexpand-p page) t
                (adw:status-page-icon-name page) "utilities-terminal-symbolic"
                (adw:status-page-title page) "Simple Lisp REPL for counter"
                (adw:status-page-description page) " ")
          (flet ((eval-expression (widget)
                   (declare (ignore widget))
                   (when expression
                     (setf (adw:status-page-description page)
                           (princ-to-string
                            (handler-case (eval expression)
                              (error (err) err)))))))
            (let ((box1
                    (gtk4:make-box :orientation gtk4:+orientation-vertical+ :spacing 0)))
              (let ((group (adw:make-preferences-group)))
                (setf (gtk4:widget-margin-all group) 10)
                (let ((row (adw:make-action-row)))
                  (setf (adw:preferences-row-title row)
                        (format nil "~A>"
                                (or (car (package-nicknames *package*))
                                    (package-name *package*))))
                  (let ((entry (gtk4:make-entry)))
                    (setf (gtk4:widget-valign entry) gtk4:+align-center+
                          (gtk4:widget-hexpand-p entry) t)
                    (gtk4:connect entry "changed"
                                  (lambda (entry)
                                    (setf expression
                                          (ignore-errors
                                           (read-from-string
                                            (entry-buffer-text
                                             (entry-buffer entry)))))
                                    (funcall
                                     (if expression
                                         #'widget-remove-css-class
                                         #'widget-add-css-class)
                                     entry "error")))
                    (gtk4:connect entry "activate" #'eval-expression)
                    (adw:action-row-add-suffix row entry))
                  (adw:preferences-group-add group row))
                (gtk4:box-append box1 group))
              (let ((carousel-box box)
                    (box2
                      (gtk4:make-box :orientation gtk4:+orientation-horizontal+ :spacing
                                     0)))
                (setf (gtk4:widget-hexpand-p box) t
                      (gtk4:widget-halign box) gtk4:+align-fill+)
                (let ((button (gtk4:make-button :label "Exit")))
                  (setf (gtk4:widget-css-classes button) '("pill")
                        (gtk4:widget-margin-all button) 10
                        (gtk4:widget-hexpand-p button) t)
                  (gtk4:connect button "clicked"
                                (lambda (button)
                                  (declare (ignore button))
                                  (gtk4:window-destroy window)))
                  (gtk4:box-append box button))
                (let ((button (gtk4:make-button :label "Eval")))
                  (setf (gtk4:widget-css-classes button)
                        '("suggested-action" "pill")
                        (gtk4:widget-margin-all button) 10
                        (gtk4:widget-hexpand-p button) t)
                  (gtk4:connect button "clicked" #'eval-expression)
                  (gtk4:box-append box button))
                (gtk4:box-append carousel-box box2))
              (setf (adw:status-page-child page) box1)))
          (adw:carousel-append carousel page))
        (gtk4:box-append box carousel)))
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
