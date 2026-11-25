(declaim (optimize (speed 0) (safety 2) (debug 3)))

;;; (ql:quickload :adw-greeter)
(in-package #:adw-greeter)
;;; (main)

(defun make-pill-button (label &key css-classes on-click)
  "Create a styled pill button and attach a click handler."
  (let ((button (gtk4:make-button :label label)))
    (setf (gtk4:widget-css-classes button) (cons "pill" css-classes)
          (gtk4:widget-margin-all button) 8)
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
           :title (format nil "~A Greeter" (lisp-implementation-type))
           :subtitle ""))
    header-bar))

(defun build-main-content (window)
  "Construct the UI hierarchy and manage greeter state via lexical closure."
  (let* ((toolbar-view (adw:make-toolbar-view))
         (root-box (gtk4:make-box :orientation gtk4:+orientation-vertical+ :spacing 12))
         (button-row (gtk4:make-box :orientation gtk4:+orientation-horizontal+
                                    :spacing 8))
         (name-label (gtk4:make-label :str "Name"))
         ;; entry
         (entry-row (adw:make-entry-row))
         (status-label (gtk4:make-label :str "Press greeter button please")))

    (labels ()

      ;; Configure layout properties
      (setf (gtk4:widget-size-request window) '(400 200)
            (gtk4:widget-margin-all root-box) 16
            (gtk4:widget-margin-all status-label) 10
            (gtk4:widget-vexpand-p status-label) t
            (gtk4:widget-halign status-label) gtk4:+align-center+
            (gtk4:widget-valign status-label) gtk4:+align-center+)

      ;; Assemble the main content
      (gtk4:box-append root-box name-label)
      (gtk4:box-append root-box entry-row)
      (gtk4:box-append button-row
                       (make-pill-button
                        "Greet"
                        :on-click (lambda ()
                                    (let ((the-text (gtk4:editable-text entry-row)))
                                      (warn "the text ~s" the-text)
                                      (setf (gtk4:label-text status-label) the-text)))))
      (gtk4:box-append root-box button-row)
      (gtk4:box-append root-box status-label)

      (adw:toolbar-view-add-top-bar toolbar-view (build-header-bar))
      (setf (adw:toolbar-view-content toolbar-view) root-box
            (adw:window-content window) toolbar-view))))

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
