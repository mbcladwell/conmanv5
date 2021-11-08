(use-modules
  (guix packages)
  ((guix licenses) #:prefix license:)
  (guix download)
  (guix build-system gnu)
  (gnu packages)
  (gnu packages autotools)
  (gnu packages guile)
  (gnu packages guile-xyz)
  (gnu packages pkg-config)
  (gnu packages texinfo)
  (gnutls))

(package
  (name "conmanv4")
  (version "0.2")
  (source "./conmanv4-0.2.tar.gz")
  (build-system gnu-build-system)
  (arguments `(#:tests? #false ; there are none
	       #:phases (modify-phases %standard-phases
       		       (add-after 'unpack 'patch-prefix
			       (lambda* (#:key inputs outputs #:allow-other-keys)
					(substitute* "conmanv4/cemail.scm"
						(("abcdefgh")
						(assoc-ref outputs "out" )) )
					#t))
		       (add-before 'install 'make-dir
			       (lambda* (#:key outputs #:allow-other-keys)
				    (let* ((out  (assoc-ref outputs "out"))
					   (bin-dir (string-append out "/bin"))
					   (dummy (mkdir-p bin-dir))
					   )            				       
				       (copy-recursively "./bin" bin-dir)
				       #t)))
		       (add-before 'install 'make-dir
			       (lambda* (#:key outputs #:allow-other-keys)
				    (let* ((out  (assoc-ref outputs "out"))
					   (scripts-dir (string-append out "/scripts"))
					   (dummy (mkdir-p scripts-dir))
					   )            				       
				       (copy-recursively "./scripts" scripts-dir)
				       #t))))))
  (native-inputs
    `(("autoconf" ,autoconf)
      ("automake" ,automake)
      ("pkg-config" ,pkg-config)
      ("texinfo" ,texinfo)))
  (inputs `(("guile" ,guile-3.0)))
  (propagated-inputs `())
  (synopsis "")
  (description "")
  (home-page "www.labsolns.com")
  (license license:gpl3+))

