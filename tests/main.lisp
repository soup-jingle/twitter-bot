(defpackage patch-bday-bot/tests/main
  (:use :cl
        :patch-bday-bot
        :rove))
(in-package :patch-bday-bot/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :patch-bday-bot)' in your Lisp.

(deftest test-target-1
  (testing "should (= 1 1) to be true"
    (ok (= 1 1))))
