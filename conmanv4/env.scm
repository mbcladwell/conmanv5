(define-module (conmanv4 env)
  #:use-module (ice-9 regex) ;;list-matches
  #:use-module  (srfi srfi-19)   ;; date time

  #:export (two-weeks-ago
	    all-chars
	    conman-store-dir
	    ))

(define conman-store-dir "abcdefgh") ;;this will be modified upon install

(define days-ago 17) ;; how many days ago to I want to analyze?
(define duration (time-difference (make-time time-utc  0 (* 86400 days-ago)) (make-time time-utc  0 0)))
(define two-weeks-ago (date->string  (time-utc->date (subtract-duration (current-time) duration)) "~Y/~m/~d"))
(define all-chars "-a-zA-Z0-9ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁłŃńŅņŇňŉŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜƏƒƠơƯƯǺǻǼǽǾǿńŻć<>~_+=,.:;()&#@®\" ")
