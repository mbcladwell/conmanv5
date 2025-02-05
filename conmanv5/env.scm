(define-module (conmanv5 env)
  #:use-module (ice-9 regex) ;;list-matches
  #:use-module  (srfi srfi-19)   ;; date time
  #:use-module (json)
  #:export (two-weeks-ago
	    all-chars
	    conman-store-dir
	    days-ago
	    three-years-ago
	    max-arts
	    laspng
	    sender
	    bcc-recipient
	    personal-email
	    home-dir
	    unsubscribe-file
	    ))

;;(define conman-store-dir "conmanstorepath") ;;this will be modified upon install
(define conman-store-dir "conmanstorepath") ;;this will be modified upon install

(define sender "mbc2025@labsolns.com")
(define bcc-recipient "mbc2025@labsolns.com")
(define personal-email "mbcladwell@labsolns.com")
(define home-dir "/home/mbc/conman")
(define unsubscribe-file (string-append home-dir "/unsubscribe.json"))	 


(define days-ago 14) ;; how many days ago to I want to analyze? usually 14      92 + feb date
;; 14*60*60*24 = 1209600
;; 15*60*60*24 =  1296000
(define duration (time-difference (make-time time-utc  0 (* 86400 days-ago)) (make-time time-utc  0 0)))
(define two-weeks-ago (date->string  (time-utc->date (subtract-duration (current-time) duration)) "~Y/~m/~d"))

(define max-arts "30") ;;maximum number of articles to pull

(define years-ago 3)
(define years-ago-in-days (* 365 years-ago))
(define duration2 (time-difference (make-time time-utc  0 (* 86400 years-ago-in-days)) (make-time time-utc  0 0)))
(define three-years-ago (date->string  (time-utc->date (subtract-duration (current-time) duration2)) "~Y-~m-~d"))
(define all-chars "-a-zA-Z0-9ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁłŃńŅņŇňŉŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜƏƒƠơƯƯǺǻǼǽǾǿńŻć<>~_+=,.:;()&#@®\" ")

;;base64 of las.png
(define laspng " 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
TkSuQmCC")
