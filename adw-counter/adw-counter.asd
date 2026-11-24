(asdf:defsystem #:adw-counter
  :description "Simple adwaita counter"
  :author "Jacek Podkanski"
  :depends-on (#:cl-gtk4.adw
               ;; #:cl-gtk4 #:cl-gdk4 #:cl-glib #:cl-cairo2
               ;; #:serapeum
               ;; #:defclass-std
               )

  :components ((:module "src"
                :serial t
                :components ((:file "package")
                             (:file "adw-counter")))))
