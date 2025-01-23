(define-module (conmanv4 cemail)
  #:use-module (conmanv4 env)
   #:use-module (ice-9 regex) ;;list-matches
   #:use-module (ice-9 textual-ports)
   #:use-module (ice-9 pretty-print)
   #:use-module (conmanv4 recs)
   #:use-module (dbi dbi)
  ; #:use-module ()
   #:export (send-report
	     send-custom-email
	     recurse-send-email
	     emails-sent
	     fname-from-email
 	    ))


(define emailer "mbc2025@labsolns.com")
(define password "7]Dg8E_zTPEU6M")
(define personal-email "mbcladwell@labsolns.com")

(define emails-sent '())  ;;if an email is sent, cons it to this list


(define (fname-from-email email)
  (let* ((at-loc (string-index email #\@))
	 (a (substring email 0 at-loc))
	 (b (string-index a #\.))
	 (c (if b (string-capitalize! (substring a 0 b))  #f)))
    c))

(define (send-email a-contact)
  ;;the ref records have journal and title info, search with pmid
  ;;input to cemail is an alist:
  ;; (("email" . "Leen.Delang@kuleuven.be")
  ;;  ("journal" . "Microorganisms")
  ;;  ("title" . "Repurposing Drugs for Mayaro Virus: Identification.... Inhibitors.")
  ;;  ("firstn" . "Rana"))
  (let* (
	 (email (contact-email a-contact))
	 (sql (format #f "SELECT * FROM unsubscribe WHERE email LIKE '~a';" email))	 
	 (ciccio (dbi-open "mysql" "plapan_conman_ad:welcome:plapan_conman:tcp:192.254.187.215:3306"))
	 (_ (dbi-query ciccio sql))  	 
	 (email (if (dbi-get_row ciccio) "null" email));;if email is in unsubscribe list set to null
	 (firstn (contact-firstn a-contact) )
	 (pmid (contact-pmid a-contact))
	 (ref (assoc pmid ref-records))
	 (title (reference-title (cdr ref)))
	 (journal (reference-journal (cdr ref)))
	 (the-list (list (cons "email" email) (cons "journal" journal)(cons "title" title)(cons "firstn" firstn)))
	 (for-report (list (cons "firstn" firstn)(cons "email" email)))
	 (dummy (if (equal? email "null") #f
		    (begin
		      (send-custom-email the-list);;comment this out to send report only
		      (set! emails-sent (cons for-report emails-sent))))))
    #f))


(define (recurse-send-email lst)
  ;;lst is the list of contact records
  ;;recurse over the contacts list and send an email if email is not null
  (if (null? (cdr lst))
      (send-email (car lst))
      (begin
	(send-email (car lst))
	(recurse-send-email (cdr lst)))))


(define (get-rand-file-name pre suff)
  (string-append "/home/admin/conman/tmp/" pre "-" (number->string (random 10000000000000000000000)) "." suff))

(define (build-sent-list lst text)
  ;;lst is the list of emails sent (("firstn" . "a")("email" . "ea"))
  ;;recurse over the list and build the email contents
  (if (null? (cdr lst))
      (begin
	(set! text (string-append text (cdr (assoc  "firstn" (car lst))) " - " (cdr (assoc  "email" (car lst))) "\n"))
	text)
      (begin
	(set! text (string-append text (cdr (assoc  "firstn" (car lst))) " - " (cdr (assoc  "email" (car lst))) "\n"))	
	(build-sent-list (cdr lst) text))))



(define (send-custom-email item)
  ;; an item is a list with needed elements from query
  ;; (("email" . "Leen.Delang@kuleuven.be")
  ;;  ("journal" . "Microorganisms")
  ;;  ("title" . "Repurposing Drugs for Mayaro Virus: Identification.... Inhibitors.")
  ;;  ("firstn" . "Rana"))
  (let* ((email (assoc-ref item "email"))
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
	 (txt-composite (format #f "Dear ~a,\n\nYour recent article entitled ~a in the journal ~a  suggests you might benefit from our product. Visit Laboratory Automation Solutions at www.labsolns.com and learn how LIMS*Nucleus can help you.\n\nLIMS*Nucleus can:\n\n-Reformat plates - four 96 well plates into a 384 well plate; four 384 well plates into a 1536 well plate\n-Associate assay data with plate sets\n-Identify hits scoring in assays using included algorithms - or write your own\n-Export annotated data\n-Generate worklists for liquid handling robots\n-Rearray hits into a smaller collection of plates\n-Track samples\n\nLIMS*Nucleus can serve as the core of a LIMS system.\nPrototype algorithms, dashboards, visualizations with R/Shiny.\nDownload a free copy or evaluate an online running instance by visiting www.labsolns.com/limsn/evaluate/\n\nFor more information contact mbcladwell@labsolns.com\n\nThank You!\n\nMortimer Cladwell MSc\nPrincipal\n\nTo unsubscribe, paste the following URL into a browser:\n\nhttps://www.labsolns.com/limsn/unsubscribe/insert.php?email=~a\n" first-name (assoc-ref item "title")(assoc-ref item "journal") email))	 
	 (txt-file-name (get-rand-file-name "rnd" "txt"))
	 (p2  (open-output-file txt-file-name))
	 (dummy (begin
		  (put-string p2 txt-composite )
		  (force-output p2)))
	 ;; (smtp-command (string-append conman-store-dir "/bin/smtp-cli --host mail.labsolns.com:587 --subject 'Multi-well plate management software' --enable-auth --user info@labsolns.com --password EKhD8GB48F8wFalt --from info@labsolns.com --to " (assoc-ref item "email") " --bcc info@labsolns.com --body-plain " txt-file-name " --body-html " html-file-name " --attach-inline " conman-store-dir "/scripts/las.png"))
	 (smtp-command (string-append "smtp-cli --host mail.labsolns.com:587 --subject 'Multi-well plate management software' --enable-auth --user " emailer " --password " password " --from " emailer " --to " (assoc-ref item "email") " --bcc " emailer " --body-plain " txt-file-name " --body-html " html-file-name " --attach-inline " conman-store-dir "/scripts/las.png"))
	 ;;comment out the next line for testing
	 (dummy (system smtp-command))
	 )
  smtp-command
  ))


(define (send-report lst alist)
  ;; lst is the stats
  ;; alist is emails that were sent, migt be null
  ;; (list (cons "firstn" firstn)(cons "email" email)) etc loop over to pull out names and emails
  (let* (
	 (str1 (string-append "Article count: " (cdr (assoc "article" lst)) "\n"))
	 (str2 (string-append "Author count: " (cdr (assoc "author" lst)) "\n"))
	 (str3 (string-append "Author find count: " (cdr (assoc "author-find" lst)) "\n"))
	 (str4 (string-append "Elapsed time: " (cdr (assoc  "elapsed-time" lst)) " minutes.\n\n"))
	 (str5 (if (null?  alist) "null" (build-sent-list alist "")))
	 (txt-composite (string-append str1 str2 str3 str4 str5))
	 (txt-file-name (get-rand-file-name "rnd" "txt"))
	 (p2  (open-output-file txt-file-name))
	 (dummy (begin
		  (put-string p2 txt-composite )
		  (force-output p2)))
	 (smtp-command (string-append "smtp-cli --host mail.labsolns.com:587 --subject 'Summary for batch " (assoc-ref lst "batchid") "' --enable-auth --user " emailer " --password " password " --from " emailer " --to " emailer " --body-plain " txt-file-name ))
	 (dummy (system smtp-command))
	 )
    #f
  
  ))

