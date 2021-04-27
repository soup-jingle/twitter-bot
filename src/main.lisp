(defpackage patch-bday-bot
  (:use :cl)
  (:import-from :patch-twitter-interface
   :tweet :dry-tweet)
  (:import-from :patch-database
   :get-birthdays :get-groups
   :get-media
   :timestamp-to-date-string
   :timestamp-to-date-list
   :do-query
   :simplify-name)
  (:export :main))
(in-package :patch-bday-bot)

(defvar media-dir "/home/patrick/prog/lisp/projects/twitterbot/media/")

;; (setf birthday-tweet-body
;;       "<~A.~A>~%~A~%Happy Birthday! ~A 🎉~%~A~&~A~&~%#~A")
(setf birthday-tweet-body
      "Today (~A.~A) is ~A's birthday! ~A 🎉~%~A~&~A~&~%#~A #~A誕生日")

(defun make-former-groups-body (groups)
  (if groups
      (format nil "‣formerly ~{~A~^,~}" groups)
      ""))

(defun make-current-groups-body (groups)
  (if groups
      (format nil "‣~{~A~^,~}" groups)
      ""))

(defun make-age (current-year birth-year)
  (if (= birth-year 4)
      ""
      (format nil "(~d)" (- current-year birth-year))))


(defun test-get-info (&key month)
  (get-birthdays :month month
		 :func #'(lambda (row)
			   (loop for group in (get-groups row)
				 collect (format nil "~A (~A-~A)"
						 (getf group :|name_roumaji|)
						 (getf group :|start_date|)
						 (getf group :|end_date|))))))

(defun test-helper (row)
  (let ((name (getf row :|name_roumaji|))
	(groups (get-groups row)))
    (loop for group in groups
	  do (format t "~A ~A" name (getf group :|name_roumaji|)))))

(defun group-row-to-info (group-row)
  (let ((name (getf group-row :|name_roumaji|))
	(start (timestamp-to-date-string (getf group-row :|start_date|) :year-only t))
	(end (timestamp-to-date-string (getf group-row :|end_date|) :year-only t)))
    (format nil "~A (~A-~A)~%" name start (if end end ""))))

(defun group-row-to-group (row)
  (let ((name (getf row :|name_roumaji|))
	(end (getf row :|end-date|)))))

(defun get-now-in-japan ()
  (multiple-value-bind (_s _m _h day month year _dow _dst _tz)
      (decode-universal-time (+ (get-universal-time)
				(* 15 60 60)))
    (list year month day)))

(defun main (&key month day dry-run)
  (let* ((current-date (get-now-in-japan))
	 (current-year (first current-date))
	 (current-month (second current-date))
	 (current-day (third current-date)))
    (let ((birthdays (get-birthdays :month (or month current-month) :day (or day current-day))))
      (loop for bday in birthdays
	    do (let* ((name (getf bday :|name_roumaji|))
		      (kanji (getf bday :|name_kanji|))
		      (birthdate (timestamp-to-date-list (getf bday :|birthdate|)))
		      (year (first birthdate))
		      (month (second birthdate))
		      (day (third birthdate))
		      ; (age (if (= year 4) "" (- current-year year)))
		      (groups (get-groups bday)))
		 (multiple-value-bind (current former)
		     (loop for group in groups
			   for group-name = (getf group :|name_roumaji|)
			   for group-kanji = (getf group :|name_kanji|)
			   if (getf group :|end_date|)
			     collect group-name into former-groups
			   else
			     collect group-name into current-groups ;; and
			     ;; collect group-kanji into hashtags
			   finally (return (values current-groups former-groups)))
					; (format t "~A~A~%~{~A~^,~}~%formerly ~{~A~^,~}~2%" name age current former)
		   (if dry-run
		       (dry-tweet (format nil birthday-tweet-body month day (simplify-name name) (make-age current-year year) (make-current-groups-body current) (make-former-groups-body former) kanji kanji))
		       (tweet (format nil birthday-tweet-body month day (simplify-name name) (make-age current-year year) (make-current-groups-body current) (make-former-groups-body former) kanji kanji)))
		   )
		 )))))
