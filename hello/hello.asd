(asdf/defsystem:defsystem "hello"
    :depends-on (#:cl-gtk4 #:cl-gdk4 #:cl-glib #:cl-cairo2)
    :components ((:file "hello")))
