(declaim (optimize (speed 0) (safety 3) (debug 3)))

;;; (ql:quickload :adw-counter)
(in-package #:adw-counter)
;;; (main)

(defparameter *application* nil)
(defparameter  *app-window* nil)

(DEFUN MAIN-WINDOW-CONTENT (WINDOW)
  (DECLARE (IGNORABLE WINDOW))
  (LET ((EXPRESSION NIL))
    ;; (gtk4:WIDGET-ADD-CSS-CLASS WINDOW "devel")
    (SETF (gtk4:WIDGET-SIZE-REQUEST WINDOW) '(400 600))
    (LET ((BOX (gtk4:MAKE-BOX :ORIENTATION gtk4:+ORIENTATION-VERTICAL+ :SPACING 0)))
      (SETF (ADW:WINDOW-CONTENT WINDOW) BOX)
      (LET ((HEADER-BAR (ADW:MAKE-HEADER-BAR)))
        (SETF (ADW:HEADER-BAR-TITLE-WIDGET HEADER-BAR)
              (ADW:MAKE-WINDOW-TITLE :TITLE (format nil "~A will be counter" (LISP-IMPLEMENTATION-TYPE))
                                     :SUBTITLE
                                     ;; (LISP-IMPLEMENTATION-VERSION)
                                     nil
                                     ))
        (gtk4:BOX-APPEND BOX HEADER-BAR))
      (LET ((CAROUSEL (ADW:MAKE-CAROUSEL)))
        (SETF (gtk4:WIDGET-HEXPAND-P CAROUSEL) T
              (gtk4:WIDGET-VEXPAND-P CAROUSEL) T
              (ADW:CAROUSEL-INTERACTIVE-P CAROUSEL) T)
        (LET ((PAGE (ADW:MAKE-STATUS-PAGE)))
          (SETF (gtk4:WIDGET-HEXPAND-P PAGE) T
                (gtk4:WIDGET-VEXPAND-P PAGE) T
                (ADW:STATUS-PAGE-ICON-NAME PAGE) "utilities-terminal-symbolic"
                (ADW:STATUS-PAGE-TITLE PAGE) "Simple Lisp REPL for counter"
                (ADW:STATUS-PAGE-DESCRIPTION PAGE) " ")
          (FLET ((EVAL-EXPRESSION (WIDGET)
                   (DECLARE (IGNORE WIDGET))
                   (WHEN EXPRESSION
                     (SETF (ADW:STATUS-PAGE-DESCRIPTION PAGE)
                           (PRINC-TO-STRING
                            (HANDLER-CASE (EVAL EXPRESSION)
                              (ERROR (ERR) ERR)))))))
            (LET ((BOX
                    (gtk4:MAKE-BOX :ORIENTATION gtk4:+ORIENTATION-VERTICAL+ :SPACING 0)))
              (LET ((GROUP (ADW:MAKE-PREFERENCES-GROUP)))
                (SETF (gtk4:WIDGET-MARGIN-ALL GROUP) 10)
                (LET ((ROW (ADW:MAKE-ACTION-ROW)))
                  (SETF (ADW:PREFERENCES-ROW-TITLE ROW)
                        (FORMAT NIL "~A>"
                                (OR (CAR (PACKAGE-NICKNAMES *PACKAGE*))
                                    (PACKAGE-NAME *PACKAGE*))))
                  (LET ((ENTRY (gtk4:MAKE-ENTRY)))
                    (SETF (gtk4:WIDGET-VALIGN ENTRY) gtk4:+ALIGN-CENTER+
                          (gtk4:WIDGET-HEXPAND-P ENTRY) T)
                    (gtk4:CONNECT ENTRY "changed"
                                  (LAMBDA (ENTRY)
                                    (SETF EXPRESSION
                                          (IGNORE-ERRORS
                                           (READ-FROM-STRING
                                            (ENTRY-BUFFER-TEXT
                                             (ENTRY-BUFFER ENTRY)))))
                                    (FUNCALL
                                     (IF EXPRESSION
                                         #'WIDGET-REMOVE-CSS-CLASS
                                         #'WIDGET-ADD-CSS-CLASS)
                                     ENTRY "error")))
                    (gtk4:CONNECT ENTRY "activate" #'EVAL-EXPRESSION)
                    (ADW:ACTION-ROW-ADD-SUFFIX ROW ENTRY))
                  (ADW:PREFERENCES-GROUP-ADD GROUP ROW))
                (gtk4:BOX-APPEND BOX GROUP))
              (LET ((CAROUSEL-BOX BOX)
                    (BOX
                      (gtk4:MAKE-BOX :ORIENTATION gtk4:+ORIENTATION-HORIZONTAL+ :SPACING
                                     0)))
                (SETF (gtk4:WIDGET-HEXPAND-P BOX) T
                      (gtk4:WIDGET-HALIGN BOX) gtk4:+ALIGN-FILL+)
                (LET ((BUTTON (gtk4:MAKE-BUTTON :LABEL "Exit")))
                  (SETF (gtk4:WIDGET-CSS-CLASSES BUTTON) '("pill")
                        (gtk4:WIDGET-MARGIN-ALL BUTTON) 10
                        (gtk4:WIDGET-HEXPAND-P BUTTON) T)
                  (gtk4:CONNECT BUTTON "clicked"
                                (LAMBDA (BUTTON)
                                  (DECLARE (IGNORE BUTTON))
                                  (gtk4:WINDOW-DESTROY WINDOW)))
                  (gtk4:BOX-APPEND BOX BUTTON))
                (LET ((BUTTON (gtk4:MAKE-BUTTON :LABEL "Eval")))
                  (SETF (gtk4:WIDGET-CSS-CLASSES BUTTON)
                        '("suggested-action" "pill")
                        (gtk4:WIDGET-MARGIN-ALL BUTTON) 10
                        (gtk4:WIDGET-HEXPAND-P BUTTON) T)
                  (gtk4:CONNECT BUTTON "clicked" #'EVAL-EXPRESSION)
                  (gtk4:BOX-APPEND BOX BUTTON))
                (gtk4:BOX-APPEND CAROUSEL-BOX BOX))
              (SETF (ADW:STATUS-PAGE-CHILD PAGE) BOX)))
          (ADW:CAROUSEL-APPEND CAROUSEL PAGE))
        (gtk4:BOX-APPEND BOX CAROUSEL)))
    (UNLESS (gtk4:WIDGET-VISIBLE-P WINDOW) (gtk4:WINDOW-PRESENT WINDOW))))

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
