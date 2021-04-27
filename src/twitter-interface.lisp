(defpackage patch-twitter-interface
  (:use :cl)
  (:import-from :chirp
   :*oauth-api-key* :*oauth-api-secret*
   :*oauth-access-token* :*oauth-access-secret*
   :account/verify-credentials :compute-status-length
   ;; :text-with-expanded-urls :text-with-markup
   ;; :status :print-object
   :statuses/update :statuses/update-with-media)
  (:import-from :config-io
   :read-config :set-values)
  )
(in-package :patch-twitter-interface)

(set-values (read-config "~/.config/lisp/twit.conf")
	    :api-key *oauth-api-key*
	    :api-secret *oauth-api-secret*
	    :access-token *oauth-access-token*
	    :access-secret *oauth-access-secret*)

;; (initiate-authentication :api-key api-key :api-secret api-secret-key)
(defun authorize ()
  (account/verify-credentials))

(defun dry-tweet (text)
  (if (< 0 (compute-status-length text) 280)
      (format t "~A~%" text)))

;; (statuses/update "test test\ntest")
(defun tweet (text)
  (if (< 0 (compute-status-length text) 280)
      (statuses/update text)))
