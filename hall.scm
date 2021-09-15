(hall-description
  (name "conmanv4")
  (prefix "")
  (version "0.1")
  (author "Mortimer Cladwell")
  (copyright (2021))
  (synopsis "")
  (description "")
  (home-page "www.labsolns.com")
  (license gpl3+)
  (dependencies `())
  (files (libraries
           ((scheme-file "conmanv4")
            (directory
              "conmanv4"
              ((compiled-scheme-file "utilities")
               (compiled-scheme-file "cemail")
               (scheme-file "cemail")
               (scheme-file "utilities")))))
         (tests ((directory "tests" ())))
         (programs ((directory "scripts" ())))
         (documentation
           ((org-file "README")
            (symlink "README" "README.org")
            (text-file "HACKING")
            (text-file "COPYING")
            (directory
              "doc"
              ((texi-file "conmanv4")
               (texi-file "version")
               (info-file "conmanv4")
               (text-file ".dirstamp")
               (text-file "stamp-vti")))
            (text-file "AUTHORS")
            (text-file "ChangeLog")))
         (infrastructure
           ((scheme-file "guix") (scheme-file "hall")))))
