#! /gnu/store/kphp5d85rrb3q1rdc2lfqc1mdklwh3qp-guile-3.0.9/bin/guile \
-e main -s
!#

(add-to-load-path "/home/mbc/projects/conmanv4")
(add-to-load-path "/gnu/store/ldba6gkvw4bjyp6qzbrij1w9nhcvjhl7-guile-gnutls-3.7.9/share/guile/site/3.0")

(use-modules (conmanv4 env)  
	     (conmanv4 utilities)
	     (conmanv4 cemail)
	     (conmanv4 recs)
	     (conmanv4 munger)
	     (conmanv4 pubmed)
	     (srfi srfi-19)   ;; date time
	     (srfi srfi-1)  ;;list searching; delete-duplicates in list 
	   ;  (ice-9 rdelim)
	   ;  (ice-9 i18n)   ;; internationalization
	   ;  (ice-9 popen)
	  ;   (ice-9 regex) ;;list-matches
	     (ice-9 pretty-print)
      	     )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; guix environment --network --expose=/etc/ssl/certs/  --manifest=manifest.scm
;; guile -e main -s ./conman.scm 7 10
;; 7 days (&reldate)
;; max 10 summaries (&retmax)

;;guix environment --pure --network --expose=/etc/ssl/certs/  --manifest=manifest.scm -- ./conman.scm 7 2

;; https://pubmed.ncbi.nlm.nih.gov/"
;; scp ~/projects/conman/conman.scm mbc@192.168.1.11:/home/mbc/projects/conman/conman.scm


;; When setting up crontab use full path to executables
;; 45 6 * * * /gnu/store/m5iprcg6pb5ch86r9agmqwd8v6kp7999-guile-3.0.5/bin/guile -L /gnu/store/l01lprwdfn8bf1ql0sdpk40cai26la6n-conmanv4-0.1/share/guile/site/3.0 -e main -s /gnu/store/l01lprwdfn8bf1ql0sdpk40cai26la6n-conmanv4-0.1/share/guile/site/3.0/conmanv4.scm 1 30



(define (main args)
  ;; args: '( "script name" "past days to query" "Number of articles to pull")
  (let* ((start-time (current-time time-monotonic))
	;; (dummy2 (log-msg 'CRITICAL (string-append "Starting up at: "  (number->string (time-second start-time)))))
	 (a (get-summaries (cadr args) (caddr args)))
	;; (_ (pretty-print a))
	 (dummy (map retrieve-article a))  ;;this does all the work; comment out last line for testing
	 (stop-time (current-time time-monotonic))
	 (elapsed-time (ceiling (/ (time-second (time-difference stop-time start-time)) 60)))
	;; (dummy3 (log-msg 'INFO (string-append "Elapsed time: " (number->string   elapsed-time) " minutes.")))
	 ;;(dummy4 (log-msg 'INFO (string-append "Article-count: " (number->string  article-count) )))
	;; (dummy5 (log-msg 'INFO (string-append "Author-count: " (number->string  author-count) )))
	;; (dummy6 (log-msg 'INFO (string-append "Author-find-email-count: " (number->string  author-find-email-count) )))
	 (stats-list (get-stats-list elapsed-time))
	 (dummy7 (send-report stats-list  emails-sent))
	;; (dummy8 (shutdown-logging))
	 )
  ;; (pretty-print a)
    (pretty-print (string-append "Elapsed time: " (number->string  elapsed-time) " minutes." ))
   ;; #f
    ))
   
;; (main '( "" "1" "30"))

;; cd /home/mbc/projects/conmanv3 &&  guix environment --manifest=manifest.scm -- guile -L /home/mbc/projects -e main -s ./conman.scm 1 30

