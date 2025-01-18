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
	     (ice-9 textual-ports)(ice-9 binary-ports)(ice-9 popen)
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
  "/home/mbc/projects/conmanv4/tests/html-out.html")

  ;; an item is a list with needed elements from query
(define item  '(("email" . "Leen.Delang@kuleuven.be")
   ("journal" . "Microorganisms")
   ("title" . "Repurposing Drugs for Mayaro Virus: Identification.... Inhibitors.")
   ("firstn" . "Rana")))
	  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;guix shell -m manifest.scm -- guile -l "gollama.scm" -c '(main "/home/mbc/projects/gollama")'
;; guile -L . -l "test-html-email.scm" -c '(main "/home/mbc/projects/conmanv4/tests")'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (main args)
  (let* ((start-time (current-time time-monotonic))
	 (email (assoc-ref item "email"))
	 (first-name (if (fname-from-email email) (fname-from-email email)(assoc-ref item "firstn")))
	 (html-composite (format #f "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\" \"http://www.w3.org/TR/REC-html40/loose.dtd\">\n<html><head><title></title></head><body style=\"font-family:Arial;font-size:14px\">\n<p>Dear ~a,<br><br>\nYour recent article entitled ~a in the journal <i>~a</i> suggests you might benefit from our product.<br>\nVisit <a href=\"http://www.labsolns.com\">Laboratory Automation Solutions</a> and learn how LIMS*Nucleus can help you.<br><br>\nLIMS*Nucleus can:<br><br>\n&nbsp; &nbsp; &nbsp; &nbsp; *&nbsp; &nbsp;Reformat plates - four 96 well plates into a 384 well plate; four 384 well plates into a 1536 well plate<br>\n&nbsp; &nbsp; &nbsp; &nbsp; *&nbsp; &nbsp;Associate assay data with plate sets<br>\n&nbsp; &nbsp; &nbsp; &nbsp; *&nbsp; &nbsp;Identify hits scoring in assays using included algorithms - or write your own<br>\n&nbsp; &nbsp; &nbsp; &nbsp; *&nbsp; &nbsp;Export annotated data<br>\n&nbsp; &nbsp; &nbsp; &nbsp; *&nbsp; &nbsp;Generate worklists for liquid handling robots<br>\n&nbsp; &nbsp; &nbsp; &nbsp; *&nbsp; &nbsp;Rearray hits into a smaller collection of plates<br>\n
&nbsp; &nbsp; &nbsp; &nbsp; *&nbsp; &nbsp;Track samples<br><br>\nLIMS*Nucleus can serve as the core of a LIMS system.<br>\nPrototype algorithms, dashboards, visualizations with R/Shiny.<br>\nDownload a free copy or evaluate an online running instance by visiting <a href=\"http://labsolns.com/software/evaluate/\">labsolns.com</a><br><br>\nThanks<br><br>\nMortimer Cladwell MSc<br>Principal<br><br>\n<a href=\"mailto:~a\">~a</a><br><br>\n<img src=\"cid:las.png\" style=\"width: 175px; height: 62px;\"><br><br><a href=\"https://www.labsolns.com/limsn/unsubscribe/insert.php?email=~a\">Unsubscribe</a></body></html>" first-name (assoc-ref item "title")(assoc-ref item "journal") personal-email personal-email email))		 
	 (dummy (system "rm /tmp/rnd*.txt"))
	 (dummy (system "rm /tmp/rnd*.html"))
	 (html-file-name (get-rand-file-name "rnd" "html"))
	 (p  (open-output-file html-file-name))
	 (dummy (begin
		  (put-string p html-composite )
		  (force-output p)))
	 
	 (_  (pretty-print (string-append "args: " args)))


	 (stop-time (current-time time-monotonic))
	 (elapsed-time (ceiling (time-second (time-difference stop-time start-time))))
	 )
    (begin
  ;;    (pretty-print (acons 1 "hello" '()) )
      (pretty-print (string-append "Shutting down after " (number->string elapsed-time) " seconds of use.")))))


