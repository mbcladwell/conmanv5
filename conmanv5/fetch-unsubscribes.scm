(define-module (conmanv5 fetch-unsubscribes)
  #:use-module (conmanv5 env)
  #:use-module (conmanv5 utilities)
  #:use-module (conmanv5 recs)
  #:use-module (ice-9 regex) ;;list-matches
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 pretty-print)
  #:use-module (srfi srfi-19)   ;; date time
  #:use-module (dbi dbi)
  #:use-module (json)
  
  ; #:use-module ()
  #:export (
	    main
 	    ))


(define all-emails '())


(define (backup-unsubscribes)
(rename-file unsubscribe-file (string-append home-dir "/conman/bak/unsubscribe-" (date->string  (current-date) "~Y~m~d~I~M") ".json")))

(define (make-json-for-unsubscribes lst)
  ;;json for import in graph-store
  (let* ((vec (list->vector lst))
	 (content (scm->json-string `(("emails" .  ,vec))))
	 (out-port (open-output-file unsubscribe-file))
	 (dummy (put-string out-port content)))
    (force-output out-port)))



(define (main args)
  (let* ((sql (format #f "SELECT email FROM unsubscribe WHERE updated > '~a';" three-years-ago))
	 (ciccio (dbi-open "mysql" "plapan_conman_ad:welcome:plapan_conman:tcp:192.254.187.215:3306"))
	 (_ (dbi-query ciccio sql))
	 (ret (dbi-get_row ciccio))	       
	 )
    (begin
      (while (not (equal? ret #f))
	       (set! all-emails (cons (assoc-ref ret "email") all-emails))
	       (set! ret (dbi-get_row ciccio))
	       );;if email is in unsubscribe list set to null
      (dbi-close ciccio)
      (if all-emails
	  (begin
	    (backup-unsubscribes)
	    (make-json-for-unsubscribes all-emails))))))

;; guix shell --manifest=manifest.scm -- guile -e '(conmanv5 fetch-unsubscribes)' -L . -s ./conmanv5.scm

  
