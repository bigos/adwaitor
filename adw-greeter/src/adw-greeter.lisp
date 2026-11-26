(declaim (optimize (speed 0) (safety 2) (debug 3)))

(in-package #:adw-greeter)

(defun make-pill-button (label &key css-classes on-click)
  "Create a styled pill button and attach a click handler."
  (let ((button (gtk4:make-button :label label)))
    (setf (gtk4:widget-css-classes button) (cons "raised" css-classes)
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
         (root-box
           (gtk4:make-box
            :orientation gtk4:+orientation-vertical+
            :spacing 16))
         (form-row
           (gtk4:make-box
            :orientation gtk4:+orientation-horizontal+
            :spacing 8))
         (breakpoint-container (adw:make-breakpoint-bin))
         (input-list (gtk4:make-list-box))
         (entry-row (adw:make-entry-row))
         (button-row
           (gtk4:make-box
            :orientation gtk4:+orientation-horizontal+
            :spacing 0))
         (status-label
           (gtk4:make-label :str "Press Greet button please")))

    (flet ((update-greeting ()
             (let ((name
                     (string-trim '(#\Space #\Tab #\Newline)
                                  (gtk4:editable-text entry-row))))
               (setf (gtk4:label-text status-label)
                     (if (string= name "")
                         "Please enter a name first."
                         (format nil "Hello, ~A!" name))))))

      ;; Configure layout and widget properties.
      (setf (adw:preferences-row-title entry-row) "Name"
            (gtk4:widget-size-request window) '(400 240)
            (gtk4:widget-margin-all root-box) 24
            (gtk4:widget-hexpand-p form-row) t
            (gtk4:widget-hexpand-p breakpoint-container) t
            (gtk4:widget-size-request breakpoint-container) '(340 120)
            (gtk4:widget-css-classes input-list) '("boxed-list")
            (gtk4:list-box-selection-mode input-list)
            gtk4:+selection-mode-none+
            (gtk4:widget-hexpand-p input-list) t
            (gtk4:widget-vexpand-p status-label) t
            (gtk4:widget-halign status-label) gtk4:+align-center+
            (gtk4:widget-valign status-label) gtk4:+align-center+

            ;; breakpoint-container owns form-row as its child
            (adw:breakpoint-bin-child breakpoint-container) form-row)

      ;; Allow pressing Enter inside the entry row.
      (gtk4:connect entry-row "entry-activated"
                    (lambda (row)
                      (declare (ignore row))
                      (update-greeting)))

      ;; Assemble the main content.
      (gtk4:list-box-append input-list entry-row)
      (gtk4:box-append
       button-row
       (make-pill-button "Greet"
                         :css-classes '("suggested-action")
                         :on-click #'update-greeting))

      (gtk4:box-append form-row input-list)
      (gtk4:box-append form-row button-row)

      ;; Switch form-row to vertical when the bin is 340 px or narrower.
      (let ((breakpoint
              (adw:make-breakpoint
               :condition
               (adw:breakpoint-condition-parse
                "max-width: 340px"))))
        ;; (adw:breakpoint-add-setter
        ;;  breakpoint form-row"orientation" gtk4:+orientation-vertical+)
        (adw:breakpoint-bin-add-breakpoint
         breakpoint-container
         breakpoint))

      (gtk4:box-append root-box breakpoint-container)
      (gtk4:box-append root-box status-label)

      (adw:toolbar-view-add-top-bar
       toolbar-view
       (build-header-bar))

      (setf (adw:toolbar-view-content toolbar-view) root-box
            (adw:window-content window) toolbar-view))))

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
    (gtk4:connect app "activate" #'on-activate)
    (gtk4:application-run app argv)))
