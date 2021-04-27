(defpackage patch-database
  (:use :cl)
  (:import-from :cl-dbi
   :with-connection :prepare
   :execute :fetch)
  (:import-from :cl-ppcre
   :regex-replace-all)
  )
(in-package :patch-database)

;; (defvar db-host "localhost")
;; (defvar db-port 3306)
(defvar db-name "idols")
(defvar db-user "root")
(defvar db-pass "27abVotrM76")

(defun simplify-name (name)
  (let* ((name (regex-replace-all "A[Aa]" name "Ā"))
	 (name (regex-replace-all "I[Ii]" name "Ī"))
	 (name (regex-replace-all "U[Uu]" name "Ū"))
	 (name (regex-replace-all "E[Ee]" name "Ē"))
	 (name (regex-replace-all "O[OoUu]" name "Ō"))
	 (name (regex-replace-all "aa" name "ā"))
	 (name (regex-replace-all "ii" name "ī"))
	 (name (regex-replace-all "uu" name "ū"))
	 (name (regex-replace-all "ee" name "ē"))
	 (name (regex-replace-all "o[ou]" name "ō"))
	 )
    name))
	  
(defun timestamp-to-date-string (timestamp &key year-only)
  (if timestamp
      (multiple-value-bind (_second _minute _hour day month year _day-of-week _dst-p _tz) (decode-universal-time timestamp)
	(if year-only
	    (format nil "~4,'0d" year)
	    (format nil "~4,'0d-~2,'0d-~2,'0d" year month day)))))

(defun timestamp-to-date-list (timestamp)
  (if timestamp
      (multiple-value-bind (_second _minute _hour day month year _day-of-week _dst-p _tz) (decode-universal-time timestamp)
	(list year month day))))
;; (defclass idol ()
;;   ((name-kanji :col-type (:varchar 20)
;; 	       :initarg :name-kanji
;; 	       :accessor idol-name-kanji)
;;    (name-roumaji :col-type (:varchar 30)
;; 		 :initarg :name-roumaji
;; 		 :accessor idol-name-roumaji)
;;    (birthdate :col-type )))

;; (defun do-query ()
;;   (let ((db (connect :database-name db-name
;; 		     :username db-user
;; 		     :password db-pass)))
;;     (unwind-protect
;; 	 (progn )
;;       (disconnect db))))
(defun process-properties (plist keys func)
  (loop while plist do
    (multiple-value-bind (key value rest) (get-properties plist keys)
      (when key (funcall func key value))
      (setf plist (cddr rest)))))

(defun print-row (row)
  (format t "~A~%" row))

;; (defun do-query (func &rest keys)
;;   (with-connection (db :mysql
;; 		       :database-name db-name
;; 		       :username db-user
;; 		       :password db-pass)
;;     (let* ((query (prepare db "select * from idol where month(birthdate)=7 and day(birthdate)=17"))
;; 	   (query (execute query)))
;;       (loop for row = (fetch query)
;; 	    while row
;; 	    do (process-properties row keys func)))))

(defun do-query (query)
  (with-connection (db :mysql
		       :database-name db-name
		       :username db-user
		       :password db-pass)
    (let* ((query* (prepare db query))
	   (query* (execute query*)))
      (loop for row = (fetch query*)
	    while row
	    collect row))))

(defun date-format (date-int)
  (let* ((year (floor date-int (* 16 32)))
	 (month (floor (- date-int year) 32))
	 (day (- date-int year month)))
    (format nil "~4,'0d-~2,'0d-~2,'0d" year month day)))

(defun get-birthdays (&key month day)
  (cond
    ((and month (not day))
     (do-query (format nil "select * from idol where month(birthdate)=~d" month)))
    ((and month day)
     (do-query (format nil "select * from idol where month(birthdate)=~d and day(birthdate)=~d" month day)))
    (t (multiple-value-bind (_second _minute _hour day month year _day-of-week _dst-p _tz) (get-decoded-time)
	 (do-query (format nil "select * from idol where month(birthdate)=~d and day(birthdate)=~d" month day))))))
;; "select idolgroup.name_roumaji as NAME_ROUMAJI,idolgroup.name_kanji as NAME_KANJI,cast(membership.start_date as char) as START_DATE,cast(membership.end_date as char) as END_DATE from idol,idolgroup,membership where idolgroup.id=membership.groupid and idol.id=membership.memberid and idol.id=~d"


(defun get-groups (idol-row)
  (do-query (format nil "select idolgroup.name_roumaji,idolgroup.name_kanji,cast(membership.start_date as char) as start_date,cast(membership.end_date as char) as end_date from idol,idolgroup,membership where idolgroup.id=membership.groupid and idol.id=membership.memberid and idol.id=~d" (getf idol-row :|id|))))

(defun get-media (idol-row)
  (do-query (format nil "select filename,filetype from media where media.idol_id=~d limit 1" (getf idol-row :|id|))))
