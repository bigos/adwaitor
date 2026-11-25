(asdf:defsystem #:adw-greeter
  :description "Simple adwaita greeter"
  :author "Jacek Podkanski"
  :depends-on (#:cl-gtk4.adw)

  :components ((:module "src"
                :serial t
                :components ((:file "package")
                             (:file "adw-greeter")))))
