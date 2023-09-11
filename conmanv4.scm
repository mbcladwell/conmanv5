(define-module (conmanv4)
#:use-module (conmanv4 env)  
#:use-module (conmanv4 utilities)
#:use-module (conmanv4 cemail)
#:use-module (conmanv4 recs)
#:use-module (conmanv4 munger)
#:use-module (conmanv4 pubmed)
#:use-module (srfi srfi-19)   ;; date time
#:use-module (srfi srfi-1)  ;;list searching; delete-duplicates in list 
#:use-module (ice-9 pretty-print)
#:export (main)
)


(define (main args)
  ;; args: '( "script name" "past days to query" "Number of articles to pull")
  (let* ((start-time (current-time time-monotonic))
	 (a (get-summaries (cadr args) (caddr args)))
	;; (_ (pretty-print a))
	 (dummy (map retrieve-article a))  ;;this does all the work; comment out last line for testing
	 (stop-time (current-time time-monotonic))
	 (elapsed-time (ceiling (/ (time-second (time-difference stop-time start-time)) 60)))
	 (stats-list (get-stats-list elapsed-time))
	 (dummy7 (send-report stats-list  emails-sent))
	 )
  ;; (pretty-print a)
    (pretty-print (string-append "Elapsed time: " (number->string  elapsed-time) " minutes." ))
   ;; #f
    ))
   

