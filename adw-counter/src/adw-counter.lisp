(declaim (optimize (speed 0) (safety 2) (debug 3)))


;;; (ql:quickload :adw-counter)
(in-package #:adw-counter)
;;; (main)


(defun make-pill-button (label &key css-classes on-click)
  "Create a styled pill button and attach a click handler."
  (let ((button (gtk4:make-button :label label)))
    (setf (gtk4:widget-css-classes button) (cons "pill" css-classes)
          (gtk4:widget-margin-all button) 10
          (gtk4:widget-hexpand-p button) t)
    (when on-click
      (gtk4:connect button "clicked"
                    (lambda (btn)
                      (declare (ignore btn))
                      (funcall on-click))))
    button))

(defun build-header-bar ()
  "Create the Adwaita header bar with dynamic Lisp implementation title."
  (let ((header-bar (adw:make-header-bar)))
    (setf (adw:header-bar-title-widget header-bar)
          (adw:make-window-title
           :title (format nil "~A Counter" (lisp-implementation-type))
           :subtitle ""))
    header-bar))

(defun build-main-content (window)
  "Construct the UI hierarchy and manage counter state via lexical closure."
  (let* ((counter 0)
         (toolbar-view (adw:make-toolbar-view))
         (root-box (gtk4:make-box :orientation gtk4:+orientation-vertical+ :spacing 0))
         (button-row (gtk4:make-box :orientation gtk4:+orientation-horizontal+ :spacing 0))
         (status-label (gtk4:make-label :str "Press counter buttons please")))

    (labels ((update-counter (delta)
               (incf counter delta)
               (setf (gtk4:label-text status-label) (princ-to-string counter))))

      ;; Configure layout properties
      (setf (gtk4:widget-size-request window) '(400 200)
            (adw:window-content window) root-box
            (gtk4:widget-hexpand-p button-row) t
            (gtk4:widget-halign button-row) gtk4:+align-fill+
            (gtk4:widget-margin-all status-label) 10
            (gtk4:widget-hexpand-p status-label) t)

      (progn
        ;; build your content in root-box as before, but WITHOUT the header bar
        (adw:toolbar-view-add-top-bar toolbar-view (build-header-bar))
        (setf (adw:toolbar-view-content toolbar-view) root-box)
        (setf (adw:window-content window) toolbar-view))

      ;; Assemble header and buttons
      (gtk4:box-append button-row
                       (make-pill-button "Exit"
                                         :on-click (lambda () (gtk4:window-destroy window))))
      (gtk4:box-append button-row
                       (make-pill-button "Decrement -"
                                         :css-classes '("suggested-action")
                                         :on-click (lambda () (update-counter -1))))
      (gtk4:box-append button-row
                       (make-pill-button "Increment +"
                                         :css-classes '("suggested-action")
                                         :on-click (lambda () (update-counter 1))))

      (gtk4:box-append root-box button-row)
      (gtk4:box-append root-box status-label))))

(defun on-activate (app)
  "Signal handler for application activation."
  (let ((window (adw:make-application-window :app app)))
    (build-main-content window)
    (gtk4:window-present window)))

(defun main (&optional argv)
  "Entry point for the Adwaita counter application."
  (unless (adw:initialized-p)
    (adw:init))
  (let ((app (adw:make-application
              :application-id "org.example.adw-counter"
              :flags 0)))
    (gtk4:connect app "activate" #'on-activate)
    (gtk4:application-run app argv)))
