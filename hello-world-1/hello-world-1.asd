(asdf:defsystem #:hello-world-1
  :description "Simple adwaita counter"
  :author "Jacek Podkanski"
  :depends-on (#:cl-gobject-introspection
               #:cl-cairo2
               #:serapeum #:defclass-std)
  :components ((:module "src"
                :components
                ((:file "hello-world-1")))))
