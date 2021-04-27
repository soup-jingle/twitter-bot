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
  :description ""
  :in-order-to ((test-op (test-op "patch-bday-bot/tests"))))

(defsystem "patch-bday-bot/tests"
  :author "Patrick Bunetic"
  :license "LLGPL"
  :depends-on ("patch-bday-bot"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for patch-bday-bot"
  :perform (test-op (op c) (symbol-call :rove :run c)))
