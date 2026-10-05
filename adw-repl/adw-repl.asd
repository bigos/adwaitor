(asdf/defsystem:defsystem "adw-repl"
    :depends-on (#:cl-gtk4 #:cl-gtk4.adw #:cl-gdk4 #:cl-glib #:cl-cairo2)
    :components ((:file "adw-repl")))
