(add-to-load-path "/home/mbc/projects/conmanv4")

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
	     (ice-9 readline)
;;	     (ice-9 iconv)
	     (ice-9 textual-ports)(ice-9 binary-ports)(ice-9 popen)
	     (json)
	     (gcrypt hash)
	     (gcrypt base16)
	     (rnrs bytevectors)
	   ;; (rnrs io ports ) 
	    (conmanv4 utilities)
	    (conmanv4 munger)
	    (conmanv4 pubmed)
	    (conmanv4 recs)
	    (conmanv4 cemail)
	    )

(define emailer "mbc2025@labsolns.com")
(define password "7]Dg8E_zTPEU6M")
(define personal-email "mbcladwell@labsolns.com")


(define (get-rand-file-name pre suff)
  "/home/mbc/projects/conmanv4/tests/text-out.txt")

  ;; an item is a list with needed elements from query
(define item  '(("email" . "Leen.Delang@kuleuven.be")
   ("journal" . "Microorganisms")
   ("title" . "Repurposing Drugs for Mayaro Virus: Identification.... Inhibitors.")
   ("firstn" . "Rana")))
	  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;guix shell -m manifest.scm -- guile -l "gollama.scm" -c '(main "/home/mbc/projects/gollama")'
;; guile -L . -l "test-text-email.scm" -c '(main "/home/mbc/projects/conmanv4/tests")'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (main args)
  (let* ((start-time (current-time time-monotonic))
	 (email (assoc-ref item "email"))
	 (first-name (if (fname-from-email email) (fname-from-email email)(assoc-ref item "firstn")))

	 (txt-composite (format #f "Dear ~a,\n\nYour recent article entitled ~a in the journal ~a  suggests you might benefit from our product. Visit Laboratory Automation Solutions at www.labsolns.com and learn how LIMS*Nucleus can help you.\n\nLIMS*Nucleus can:\n\n-Reformat plates - four 96 well plates into a 384 well plate; four 384 well plates into a 1536 well plate\n-Associate assay data with plate sets\n-Identify hits scoring in assays using included algorithms - or write your own\n-Export annotated data\n-Generate worklists for liquid handling robots\n-Rearray hits into a smaller collection of plates\n-Track samples\n\nLIMS*Nucleus can serve as the core of a LIMS system.\nPrototype algorithms, dashboards, visualizations with R/Shiny.\nDownload a free copy or evaluate an online running instance by visiting www.labsolns.com/limsn/evaluate/\n\nFor more information contact mbcladwell@labsolns.com\n\nThank You!\n\nMortimer Cladwell MSc\nPrincipal\n\nTo unsubscribe, paste the following URL into a browser:\n\nhttps://www.labsolns.com/limsn/unsubscribe/insert.php?email=~a\n" first-name (assoc-ref item "title")(assoc-ref item "journal") email))
	 (txt-file-name (get-rand-file-name "rnd" "txt"))
	 (p2  (open-output-file txt-file-name))
	 (dummy (begin
		  (put-string p2 txt-composite )
		  (force-output p2)))

	 (stop-time (current-time time-monotonic))
	 (elapsed-time (ceiling (time-second (time-difference stop-time start-time))))
	 )
    (begin
  ;;    (pretty-print (acons 1 "hello" '()) )
      (pretty-print (string-append "Shutting down after " (number->string elapsed-time) " seconds of use.")))))


