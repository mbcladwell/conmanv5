#! /gnu/store/kphp5d85rrb3q1rdc2lfqc1mdklwh3qp-guile-3.0.9/bin/guile \
-e main -s
!#

 (add-to-load-path "/home/mbc/projects/conmanv4")
(add-to-load-path "/gnu/store/ldba6gkvw4bjyp6qzbrij1w9nhcvjhl7-guile-gnutls-3.7.9/share/guile/site/3.0")

 ;;(add-to-load-path "/home/admin/projects")

(use-modules (conmanv4 env)  
	     (conmanv4 utilities)
	     (conmanv4 cemail)
	     (conmanv4 recs)
	     (conmanv4 munger)
	     (web client)
	     (srfi srfi-19)   ;; date time
	     (srfi srfi-1)  ;;list searching; delete-duplicates in list 
	     (web response)
	     (web request)
	     (web uri)
	     (ice-9 rdelim)
	     (ice-9 i18n)   ;; internationalization
	     (ice-9 popen)
	     (ice-9 regex) ;;list-matches
	     (ice-9 receive)	     
	     (ice-9 string-fun)  ;;string-replace-substring
	     (ice-9 pretty-print)
          ;;   (logging logger)
          ;;   (logging rotating-log)
          ;;   (logging port-log)
	     )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; guix environment --network --expose=/etc/ssl/certs/  --manifest=manifest.scm
;; guile -e main -s ./conman.scm 7 10
;; 7 days (&reldate)
;; max 10 summaries (&retmax)

;;guix environment --pure --network --expose=/etc/ssl/certs/  --manifest=manifest.scm -- ./conman.scm 7 2

;; /gnu/store/0w76khfspfy8qmcpjya41chj3bgfcy0k-guile-3.0.4/bin/guile

;; psql -U ln_admin -h 192.168.1.11 -d conman

;; https://pubmed.ncbi.nlm.nih.gov/"
;; scp ~/projects/conman/conman.scm mbc@192.168.1.11:/home/mbc/projects/conman/conman.scm


;; When setting up crontab use full path to executables
;; 45 6 * * * /gnu/store/m5iprcg6pb5ch86r9agmqwd8v6kp7999-guile-3.0.5/bin/guile -L /gnu/store/l01lprwdfn8bf1ql0sdpk40cai26la6n-conmanv4-0.1/share/guile/site/3.0 -e main -s /gnu/store/l01lprwdfn8bf1ql0sdpk40cai26la6n-conmanv4-0.1/share/guile/site/3.0/conmanv4.scm 1 30

;; 14*60*60*24 = 1209600
;; 15*60*60*24 =  1296000



;; '((("fname" . "joey")("email" . "joey@acme.com") ))


;;(setup-logging)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Find missing email methods
;; 
;; (find-email aoi)
;;     |
;;     |--> (find-fl-aoi aoi)                                                OK
;;     |         | find articles where author of interest
;;     |         | is the first or last author
;;     |         |
;;     |         |--> (get-articles-for-auth aoi)                            OK
;;     |         |        get N article for an author
;;     |         |
;;     |         |--> (map first-or-last-auth? aoi pmid)                     OK
;;     |                  determine whether the author is the
;;     |                  first or last author of article
;;     |
;;     |--> (map search-fl-for-auth aoi pmid)
;;               Pull down a single article where aoi
;;               is the first or last author and search
;;               html for email address



(define (get-articles-for-auth auth)
  ;;this method supplies pmids for email search
  ;;search returns nothing if too many (20) pmids submitted
  ;;work with 10 for now
  (let* ( (authmod (string-replace-substring auth " " "+"))
	 (url (string-append "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=" (uri-encode authmod) "[auth]&retmax=10"))
	 (summary-url  (uri-encode url )) 
	 (the-body   (receive (response-status response-body)
	 		 (http-request url) response-body))
	 (dummy (set! author-find-email-count (+ author-find-email-count 1)))
	 (dummy2 (sleep 1))
	 (a (map match:substring  (list-matches "<Id>[0-9]{8}</Id>" the-body )))
	 (b (map (lambda (x) (substring x 4 (- (string-length x) 5))) a))
	)
    b))

;; (get-articles-for-auth "Marjanović Ž")
  


 ;; (pretty-print (find-fl-aoi "Church G"))
 ;; (pretty-print  (get-articles-for-auth "Marjanović Ž"))

(define (search-fl-for-auth auth pmid-list)
  ;; search article where author of interest in either first or last
  ;; search for email id
  ;; articles is a list of pmids that have already been determined by find-fl-auth
  ;; to have the author of interest as first or last author
  ;; returns email or #f
  ;; process the list until you find an email
 (if (null? pmid-list) #f
      (let* ((url (string-append "https://pubmed.ncbi.nlm.nih.gov/" (car pmid-list) "/"))
	     (the-body (receive (response-status response-body)
			   (http-request url) response-body))
	     (dummy (sleep 2))
	     (coord-start (string-match "<div class=\"affiliations\">" the-body ))
	     (coord-end (string-match " <ul class=\"identifiers\" id=\"full-view-identifiers\">" the-body ))
	     (affil-chunk (if coord-start (xsubstring the-body (match:start coord-start) (match:start coord-end)) #f))
	     (first-space  (string-contains auth " "))
	     (lname (string-downcase (xsubstring auth 0  first-space )))	  
	     (a (if affil-chunk (regexp-exec generic-email-regexp affil-chunk) #f))
	     (email  (if a (xsubstring (match:string a) (match:start a) (match:end a)) #f)))
	(if email email (search-fl-for-auth auth (cdr pmid-list))))))


  
;; (search-fl-for-auth "Church G" "32753383")   this one has the email address
;; (search-fl-for-auth "Church G" "32381713")



(define (get-id-authors x)
  ;;used in get-summaries
  (let* ((a (map match:substring  (list-matches "<Item Name=\"Author\" Type=\"String\">[-a-zA-Z0-9ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁłŃńŅņŇňŉŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜƏƒƠơƯƯǺǻǼǽǾǿńŻć<>~_+=,.:;()&#@\" ]+</Item>" x )))
	 (b (map (lambda (x) (substring x 34 (- (string-length x) 7)) ) a))
	 (c (string-match "<Id>[0-9]{8}</Id>" x))
	 (d (xsubstring x (+ (match:start c) 4) (- (match:end c) 5))))
    (cons (list d) (list b))))

;; (define (get-title x)
;;   (let* ((a (map match:substring  (list-matches "<Item Name=\"Author\" Type=\"String\">[-a-zA-Z0-9ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁłŃńŅņŇňŉŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜƏƒƠơƯƯǺǻǼǽǾǿńŻć<>~_+=,.:;()&#@\" ]+</Item>" x )))
;; 	 (b (map (lambda (x) (substring x 34 (- (string-length x) 7)) ) a))
;; 	 (c (string-match "<Id>[0-9]{8}</Id>" x))
;; 	 (d (xsubstring x (+ (match:start c) 4) (- (match:end c) 5))))
;;     (cons (list d) (list b))))


(define (get-summaries reldate retmax)
  ;; this is the initializing method
  (let*((db "pubmed")
;;	(query (string-append "96+multi+well+OR+high-throughput+screening+assay+(" (uri-encode two-weeks-ago) "[epdat])"))
	(query (string-append "(((96+well+plate)+OR+(high+throughput+screening))+OR+(multi+well+plate+assay))+AND+((\"" (uri-encode two-weeks-ago) "\"[Date+-+Entry]+%3A+\"" (uri-encode two-weeks-ago) "\"[Date+-+Entry]))"))
	
	
	(base "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/")
	;; (define url (string-append base  "esearch.fcgi?db=" db "&term=" query "&usehistory=y"))
	(url (string-append base  "esearch.fcgi?db=" db "&term=" query "&retmax=" retmax))
	(the-body   (receive (response-status response-body)
			(http-request url) response-body))
	(dummy (sleep 1))
        (all-ids-pre   (map match:substring  (list-matches "<Id>[0-9]+</Id>" the-body ) ))
	(e (if (not (null? all-ids-pre))
	       (let* ((all-ids (map (lambda (x) (string-append (xsubstring x 4 12) ",")) all-ids-pre))
		      (all-ids-concat (string-concatenate all-ids))
		      (all-ids-concat (xsubstring all-ids-concat 0 (- (string-length all-ids-concat) 1)))
		      (summary-url (string-append base "esummary.fcgi?db=" db "&id=" all-ids-concat  ))
		      ;; (summary-url (string-append base "esummary.fcgi?db=" db "&id=" all-ids-concat "&version=2.0" ))
		      (all-summaries   (receive (response-status response-body)
					   (http-request summary-url) response-body))
		      (b (find-occurences-in-string "<DocSum>" all-summaries))
		      (c (map (lambda (x) (substring all-summaries (car x) (cdr x))) b))
		      (d (recurse-remove-italicization c '()))
		      ;; this is where I will insert the ref table processing
		      ;; this creates ref-records, an a-list of references
		      (dummy (get-pmid-jrn-title d))
		      ) 
		 (map get-id-authors d)
		 )		      
               '() ))  )
  ;;  (pretty-print e)))
   e))

;; (pretty-print (get-summaries "40" "3"))



(define (recurse-get-unique-emails contacts unique-emails)
  ;; input contacts records
  ;; output is a list of unique emails, but still contains nulls
  (if (null? (cdr contacts))
      (begin
	(cons (contact-email (car contacts)) unique-emails )
	(delete-duplicates! unique-emails))
      (recurse-get-unique-emails (cdr contacts)
				 (cons (contact-email (car contacts)) unique-emails ))))

 (define (scan-records-for-email contacts email)
   (if (null? (cdr contacts))
       (car contacts) ;;the only one left
       (begin
	 (if (string= (contact-email (car contacts)) email)
	     (car contacts)
	     (scan-records-for-email (cdr contacts) email)))))

(define (get-unique-email-contacts contacts unique-emails unique-contacts)
     (if (null? (cdr unique-emails))
	 (cons (scan-records-for-email contacts (car unique-emails)) unique-contacts)	   
	 (get-unique-email-contacts contacts (cdr unique-emails)
				    (cons (scan-records-for-email contacts (car unique-emails)) unique-contacts) )))


(define (retrieve-article a-summary)
  ;;this does all the work; summary list repeately processed article by article
  ;;including send email
  (let* ((pmid (caar a-summary))
	 (auth-list (cadr a-summary))
	 (indexed-auth-lst (recurse-lst-add-index 1 auth-list '()))
	 (url (string-append "https://pubmed.ncbi.nlm.nih.gov/" pmid "/"))
	 (the-body (receive (response-status response-body)
		       (http-request url) response-body))
	 (dummy (set! article-count (+ article-count 1)))
	 (dummy2 (sleep 1))
	 ;; must test here for the text </a><sup class=\"equal-contrib-container OR </a><sup class=\"affiliation-links\"><spa
	 ;; if not present, no affiliations, move on
	 (author-records (if the-body (get-authors-records the-body) #f))
	 (affils-alist '())
	 (affils-alist (if (null? author-records) #f (get-affils-alist the-body )))
	 (author-records2 (if (null? affils-alist) #f (recurse-update-contact-records 1 pmid indexed-auth-lst author-records affils-alist '())))
	 (author-records3 (if (null? author-records2) #f (recurse-get-missing-email author-records2 '())))
	 (unique-emails (recurse-get-unique-emails author-records3 '()))
	 (author-records4 (get-unique-email-contacts author-records3 unique-emails '()))
	 ;;comment next line for testing and pretty print
;;	 (dummy4 (if (null? author-records4) #f (recurse-send-email author-records4) ))
	 )     
   ;; (pretty-print author-records)
    #f
    ))


;;(pretty-print (retrieve-article "33919699"))


;; provides a list of articles.  One article looks like:
;; (full_name first_name last_name id id affiliation [email])  e.g.:
;;
  ;; (("Peng Song"
 ;;  "Peng"
 ;;  "Song"
 ;;  "1"
 ;;  "1"
 ;;  "College of Water Resources and Civil Engineering, China Agricultural University, Beijing 100083, China."
 ;;  "null")
 ;; ("Yang Xiao"
 ;;  "Yang"
 ;;  "Xiao"
 ;;  "1"
 ;;  "1"
 ;;  "College of Water Resources and Civil Engineering, China Agricultural University, Beijing 100083, China."
 ;;  "null")
 ;; ("Zhiyong Jason Ren"
 ;;  "Zhiyong"
 ;;  "Ren" etc.....
;;
;; Must merge the names with the affiliations
;; Not all affiliations will contain an email address
;; provide url with &metadataPrefix=pmc_fm&tool=cntmgr&email=info@labsolns.com so I may be contacted prior to banning

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load the ref table for custom emails



(define (process-vec-pmid lst results)
  ;;results passed in is '()
  (if (null? (cdr lst))
      (begin
	(if (null? (car lst))
	    (set! results (append  results '("null")))
	    (set! results (append  results (list (xsubstring (match:string (caar lst) )  (+ (match:start (caar lst)) 4) (- (match:end (caar lst)) 5) )))))
	results)
      (begin
	(if (null? (car lst))
	    (set! results (append  results '("null")))
            (set! results (append  results (list (xsubstring (match:string (caar lst) )  (+ (match:start (caar lst)) 4) (- (match:end (caar lst)) 5) )))))
	(process-vec-pmid (cdr lst) results))))

(define (process-vec-journal lst results)
  ;;results passed in is '()
  (if (null? (cdr lst))
      (begin
	(if (null? (car lst))
	    (set! results (append  results '("null")))
	    (set! results (append  results (list (xsubstring (match:string (caar lst) )  (+ (match:start (caar lst)) 43) (- (match:end (caar lst)) 7) )))))
	results)
      (begin
	(if (null? (car lst))
	    (set! results (append  results '("null")))
            (set! results (append  results (list (xsubstring (match:string (caar lst) )  (+ (match:start (caar lst)) 43) (- (match:end (caar lst)) 7) )))))
	(process-vec-journal (cdr lst) results))))

(define (process-vec-title lst results)
  ;;results passed in is '()
  (if (null? (cdr lst))
      (begin
	(if (null? (car lst))
	    (set! results (append  results '("null")))
	    (set! results (append  results (list (xsubstring (match:string (caar lst) )  (+ (match:start (caar lst)) 33) (- (match:end (caar lst)) 7) )))))
	results)
      (begin
	(if (null? (car lst))
	    (set! results (append  results '("null")))
            (set! results (append  results (list (xsubstring (match:string (caar lst) )  (+ (match:start (caar lst)) 33) (- (match:end (caar lst)) 7) )))))
	(process-vec-title (cdr lst) results))))



(define (get-pmid-jrn-title x)
  ;; this should come right after:
  ;; b (find-occurences-in-string "<DocSum>" all-summaries))
  ;; c (map (lambda (x) (substring all-summaries (car x) (cdr x))) b))
  ;; i.e. the summaries list is the input - pass in c
  ;; note that failed title or journal searches will insert "null"; failure is probably a missing character in the search term e.g. ®
  (let* ((search-term (string-append "<Id>[0-9]+</Id>"))
	 (a  (map list-matches  (circular-list search-term) x ))
	 (b (process-vec-pmid a '()))  ;;all PMIDs
	 (search-term (string-append "<Item Name=\"Title\" Type=\"String\">[" all-chars  "]+</Item>"))
	 (c  (map list-matches  (circular-list search-term) x ))
	 (d (process-vec-title c '()))  ;;Title
	 (search-term (string-append "<Item Name=\"FullJournalName\" Type=\"String\">[" all-chars  "]+</Item>"))
	 (e  (map list-matches  (circular-list search-term) x ))
	 (f (process-vec-journal e '()))  ;;Journals
	 )
;;    (pretty-print f)))
    (make-ref-records b f d )))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; email
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (find-fl-aoi auth)
  ;; find first last author of interest (aoi)
  ;; return a list of pmids where the auth is the first or last author
  (let* ((a (get-articles-for-auth auth))
	 ;;next line returns nothing if too many pmids submitted
	 (b   (map first-or-last-auth? (circular-list auth) a))
	 (holder '())
	 (dummy (if b (map (lambda (x y) (if x (set! holder (append! holder (list y))) #f)) b a) #f))
	 )
 ;;   (pretty-print holder)))
     holder))

(define (find-email auth)
  ;;used in get-missing-email
  ;; fl-pmids are the pmids that have the author of interest as first or last author
  ;; note that more than 20 pmids may be triggering server to abort
  (let* (
	 (fl-pmids (find-fl-aoi auth))
	 (dummy (sleep 1))
	 (email (if fl-pmids (search-fl-for-auth  auth fl-pmids) #f))
	 )
      (if email email "null")))



(define (get-missing-email the-contact contacts-out)
  ;;input: contact records with all info but maybe email is missing
  ;;if email is missing find it
  ;;I will also count contacts in this method
      (let* (
	     (email (contact-email the-contact))
	     (email-null?   (string=? "null" email))
	     (deplorables '( "Pfizer" "China"))
	     (affil (contact-affil the-contact))
	     (ok-affiliation? (not (any-not-false? (map string-contains-ci (circular-list affil) deplorables))))
	     (auth-name (contact-qname the-contact))
	     (new-email (if (and email-null?  ok-affiliation?) (find-email auth-name) email))
	     (dummy (set! author-count (+ author-count 1)))
	     (dummy (set-contact-email! the-contact new-email))
	     (dummy (set! contacts-out (cons the-contact contacts-out)))
	     )
	contacts-out))


(define (recurse-get-missing-email contacts contacts-out)
  ;;input: contact records with all info but maybe email is missing
  (if (null? (cdr contacts))     
	(get-missing-email (car contacts) contacts-out )   
	(recurse-get-missing-email (cdr contacts)
				   (get-missing-email (car contacts) contacts-out))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; email end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




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
	 (stats-list (list (cons "batchid" batch-id) (cons "article" (number->string article-count)) (cons "author" (number->string author-count)) (cons "author-find" (number->string author-find-email-count)) (cons "elapsed-time" (number->string elapsed-time))))
	 (dummy7 (send-report stats-list  emails-sent))
	;; (dummy8 (shutdown-logging))
	 )
  ;; (pretty-print a)
    (pretty-print (string-append "Elapsed time: " (number->string  elapsed-time) " minutes." ))
   ;; #f
    ))
   
;; (main '( "" "1" "30"))

;; cd /home/mbc/projects/conmanv3 &&  guix environment --manifest=manifest.scm -- guile -L /home/mbc/projects -e main -s ./conman.scm 1 30

