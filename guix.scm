(use-modules
  (guix packages)
  ((guix licenses) #:prefix license:)
  (guix download)
  (guix build-system gnu)
;;  (guix build-system guile)
  (guix profiles)
  (gnu packages)
  (gnu packages autotools)
  (gnu packages guile)
  ;;  (gnu packages guile-xyz)
  (artanis artanis)
  (artanis utils)
  (gnu packages pkg-config)
  (gnu packages texinfo)
  (gnu packages bash)
  (gnu packages linux)
  (gnu packages databases)
;;  (gnu packages nss)
;;  (gnu packages tls)
;;  (gnu packages libffi)
  ;;  (gnu packages crypto)
  (conmanv4 logging)
  (conmanv4 utilities)
  (guix git-download)
  (logging logger)
  (logging rotating-log)
  (logging port-log)
  (gnutls) 
)

(define-public conmanv4
  (package
    (name "conmanv4")
    (version "0.1.0")
    (source (origin
	     ;; (method git-fetch)
	     ;; (uri (git-reference 
	     ;; 	   (url "https://github.com/mbcladwell/limsn.git")
	     ;; 	   (commit "8669fbe0ef30bac94bc86d866b91cffcdd2bf7c1")))    
             ;; (sha256
             ;;  (base32
             ;;   "11p4bgi8fvnzhxb1x73sndkrhr7yyj4hyhx8s8zf2f1mdvkd4ahs"))
	     
	      (method url-fetch)
	     (uri "file:///home/mbc/projects/conmanv4/conmanv4-0.1.tar.gz")    
             (sha256
	     
              (base32
               "1a5lbdby17vdvn67nqrm0k9zq8kpg4wi3s25v9bcn6wp6zxz1936"))

             (modules '((guix build utils)(guile-dbi) ))
              ))
    (build-system gnu-build-system)
    (inputs
     `(("guile" ,guile-3.0)
  ;;     ("nss" ,nss)
       ;;    ("nspr" ,nspr)
     ;;  ("guile-dbi" ,guile-dbi)
  ;;     ("utilities" ,utilities)
       ))
    (native-inputs
     `(("bash"       ,bash)         ;for the `source' builtin
       ("pkgconfig"  ,pkg-config)
       ("util-linux" ,util-linux))) ;for the `script' command
    
    (synopsis "Contact Manager")
    (description "auto-email contacts extracted from PubMed")
    (home-page "http://www.labsolns.com/")
    (license (list license:gpl3+ license:lgpl3+)))) ;dual license

conmanv4


