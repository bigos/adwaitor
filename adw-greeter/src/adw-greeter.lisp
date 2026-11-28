(in-package #:adw-greeter)

(defun make-action-button (label &key css-classes on-click)
  "Create a styled button and attach a click handler."
  (let ((button (gtk4:make-button :label label)))
    (setf (gtk4:widget-css-classes button) css-classes
          (gtk4:widget-valign button) gtk4:+align-center+)
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

(defun add-action (action-map name callback)
  "Register a stateless GSimpleAction on ACTION-MAP."
  (let ((action (gio:make-simple-action :name name :parameter-type nil)))
    (gio:action-map-add-action action-map action)
    (gtk4:connect action "activate"
                  (lambda (act param)
                    (declare (ignore act param))
                    (funcall callback)))
    action))

(defun build-main-content (window)
  "Construct the UI hierarchy and manage greeter state via lexical closure."
  (let* ((toolbar-view (adw:make-toolbar-view))
         (root-box (gtk4:make-box :orientation gtk4:+orientation-vertical+ :spacing 16))
         (form-row (gtk4:make-box :orientation gtk4:+orientation-horizontal+ :spacing 8))
         (input-list (gtk4:make-list-box))
         (entry-row (adw:make-entry-row))
         (status-page (adw:make-status-page)))

    (labels ((clear-validation-error ()
               (gtk4:widget-remove-css-class entry-row "error"))

             (reset-greeter ()
               (clear-validation-error)
               (setf (gtk4:editable-text entry-row) ""
                     (adw:status-page-icon-name status-page) "dialog-question-symbolic"
                     (adw:status-page-title status-page) "Welcome"
                     (adw:status-page-description status-page) "Enter your name above and press Greet.")
               (gtk4:widget-grab-focus entry-row))

             (update-greeting ()
               (let ((name (string-trim '(#\Space #\Tab #\Newline)
                                        (gtk4:editable-text entry-row))))
                 (if (string= name "")
                     (progn
                       (gtk4:widget-add-css-class entry-row "error")
                       (setf (adw:status-page-icon-name status-page) "dialog-warning-symbolic"
                             (adw:status-page-title status-page) "Name Required"
                             (adw:status-page-description status-page) "Please enter a name before greeting.")
                       (gtk4:widget-grab-focus entry-row))
                     (progn
                       (clear-validation-error)
                       (setf (adw:status-page-icon-name status-page) "face-smile-symbolic"
                             (adw:status-page-title status-page) (format nil "Hello, ~A!" name)
                             (adw:status-page-description status-page) "Press Escape to clear and greet someone else."))))))

      ;; Configure window and layout properties
      (setf (gtk4:window-default-size window) '(440 360)
            (gtk4:widget-margin-all root-box) 24
            (gtk4:widget-hexpand-p form-row) t
            (adw:preferences-row-title entry-row) "Name"
            (gtk4:widget-css-classes input-list) '("boxed-list")
            (gtk4:list-box-selection-mode input-list) gtk4:+selection-mode-none+
            (gtk4:widget-hexpand-p input-list) t
            (gtk4:widget-vexpand-p status-page) t)

      ;; Initialize default status page state
      (reset-greeter)

      ;; Window-level action for Escape shortcut
      (add-action window "clear" #'reset-greeter)

      ;; Signals: Enter key submits, typing clears validation errors
      (gtk4:connect entry-row "entry-activated"
                    (lambda (row)
                      (declare (ignore row))
                      (update-greeting)))
      (gtk4:connect entry-row "changed"
                    (lambda (row)
                      (declare (ignore row))
                      (clear-validation-error)))

      ;; Assemble the widget hierarchy
      (gtk4:list-box-append input-list entry-row)
      (gtk4:box-append form-row input-list)
      (gtk4:box-append form-row
                       (make-action-button "Greet"
                                           :css-classes '("suggested-action")
                                           :on-click #'update-greeting))

      (gtk4:box-append root-box form-row)
      (gtk4:box-append root-box status-page)

      (adw:toolbar-view-add-top-bar toolbar-view (build-header-bar))
      (setf (adw:toolbar-view-content toolbar-view) root-box
            (adw:window-content window) toolbar-view)

      ;; Focus entry once realized/mapped
      (gtk4:widget-grab-focus entry-row))))

(defun on-activate (app)
  "Signal handler for application activation."
  (let ((window (adw:make-application-window :app app)))
    (build-main-content window)
    (gtk4:window-present window)))

(defun main (&optional argv)
  "Entry point for the Adwaita greeter application."
  (unless (adw:initialized-p)
    (adw:init))
  (let ((app (adw:make-application
              :application-id "org.example.adw-greeter"
              :flags 0)))
    (add-action app "quit" (lambda () (gio:application-quit app)))
    (setf (gtk4:application-accels-for-action app "app.quit") '("<Control>q")
          (gtk4:application-accels-for-action app "win.clear") '("Escape"))
    (gtk4:connect app "activate" #'on-activate)
    (gtk4:application-run app argv)))
