(define-module (conmanv4 env)
  #:use-module (ice-9 regex) ;;list-matches
  #:use-module  (srfi srfi-19)   ;; date time

  #:export (two-weeks-ago
	    all-chars
	    conman-store-dir
	    days-ago
	    max-arts
	    ))

;;(define conman-store-dir "conmanstorepath") ;;this will be modified upon install
(define conman-store-dir "/home/admin/conmanv4") ;;this will be modified upon install


(define days-ago 14) ;; how many days ago to I want to analyze?
;; 14*60*60*24 = 1209600
;; 15*60*60*24 =  1296000

(define max-arts "30") ;;maximum number of articles to pull

(define duration (time-difference (make-time time-utc  0 (* 86400 days-ago)) (make-time time-utc  0 0)))
(define two-weeks-ago (date->string  (time-utc->date (subtract-duration (current-time) duration)) "~Y/~m/~d"))
(define all-chars "-a-zA-Z0-9ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁłŃńŅņŇňŉŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜƏƒƠơƯƯǺǻǼǽǾǿńŻć<>~_+=,.:;()&#@®\" ")
