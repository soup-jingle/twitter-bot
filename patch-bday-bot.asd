(defsystem "patch-bday-bot"
  :version "0.1.0"
  :author "Patrick Bunetic <soup-jingle@protonmail.com>"
  :license "LLGPL"
  :depends-on ("cl-ppcre"
	       "chirp"
               "cl-dbi"
	       "config-io")
  :components ((:module "src"
                :components
                ((:file "database")
		 (:file "twitter-interface")
		 (:file "main"))))
  :description "")
