(add-to-load-path "/home/mbc/projects/conmanv4")
(add-to-load-path "/home/mbc/projects/conmanv4/tests")
(add-to-load-path "/gnu/store/x388h9kr9sx99pm2wq6fk0ga3cip5sjx-guile-dbi-2.1.8/share/guile/site/2.2")

(use-modules (srfi srfi-19)   ;; date time
	     (srfi srfi-1)  ;;list searching; delete-duplicates in list 
	     (srfi srfi-9)  ;;records
	     (srfi srfi-11)
	     (srfi srfi-64)
	     (web response)(web request) (web uri)(web client) (web http)(ice-9 receive)
	     (ice-9 pretty-print)
	     (ice-9 regex) ;;list-matches
	     (ice-9 string-fun)  ;;string-replace-substring	   
	     (ice-9 rdelim)
	     (ice-9 i18n)   ;; internationalization	     	     	     
;;	     (ice-9 readline)
;;	     (ice-9 iconv)
	     (ice-9 textual-ports)(ice-9 binary-ports)(ice-9 popen)
;;	     (json)
;;	     (gcrypt hash)
;;	     (gcrypt base16)
	     (rnrs bytevectors)
	   ;; (rnrs io ports ) 
	    (conmanv4 utilities)
	    (conmanv4 munger)
	    (conmanv4 pubmed)
	    (conmanv4 recs)
	    (conmanv4 cemail)
	    (dbi dbi)
	    )

(define emailer "mbc2025@labsolns.com")
(define password "7]Dg8E_zTPEU6M")
(define personal-email "mbcladwell@labsolns.com")


(define (get-rand-file-name pre suff)
  "/home/mbc/projects/conmanv4/tests/checkunsubscribe.txt")

  ;; an item is a list with needed elements from query
(define item
  '(("email" . "Leen.Delang@kuleuven.be")
   ("journal" . "Microorganisms")
   ("title" . "Repurposing Drugs for Mayaro Virus: Identification.... Inhibitors.")
   ("firstn" . "Rana")))
	  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;guix shell -m manifest.scm -- guile -l "gollama.scm" -c '(main "/home/mbc/projects/gollama")'
;; guile -l "check-unsubscribe.scm" -c '(main "/home/mbc/projects/conmanv4/tests")'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (main args)
  (let* ((start-time (current-time time-monotonic))
	 (email (assoc-ref item "email"))
	 (first-name (if (fname-from-email email) (fname-from-email email)(assoc-ref item "firstn")))
	;; (email "null")
	 (txt-file-name (get-rand-file-name "rnd" "txt"))
	;; (sql (string-append "SELECT * FROM unsubscribe WHERE email LIKE 'plapan@disroot.org'"))
	 (sql (format #f "SELECT * FROM unsubscribe WHERE email LIKE '~a';" email))	 
	 (ciccio (dbi-open "mysql" "plapan_conman_ad:welcome:plapan_conman:tcp:192.254.187.215:3306"))
	;; (_ (display ciccio))	 
	 (_ (dbi-query ciccio sql))  	 
	 (oktosend? (if (dbi-get_row ciccio) #f #t))
	 (_ (display oktosend?))	 
	 (stop-time (current-time time-monotonic))
	 (elapsed-time (ceiling (time-second (time-difference stop-time start-time))))
	 )
    
     ;; (display ciccio)(newline)

      (pretty-print (string-append "Shutting down after " (number->string elapsed-time) " seconds of use."))))


