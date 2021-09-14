(hall-description
  (name "conmanv4")
  (prefix "")
  (version "0.1")
  (author "mbcladwell")
  (copyright (2021))
  (synopsis "")
  (description "")
  (home-page "www.labsolns.com")
  (license gpl3+)
  (dependencies `())
  (files (libraries
           ((directory
              "conmanv4"
              ((scheme-file "logging")
              
               (scheme-file "cemail")
               (scheme-file "utilities")))))
         (tests ((directory "tests" ())))
         (programs ((directory "scripts" ())))
         (documentation
           ((org-file "README")
            (symlink "README" "README.org")
            (text-file "HACKING")
            (text-file "COPYING")
            (directory "doc" ((texi-file "conmanv4")))))
         (infrastructure
           ((scheme-file "guix") (scheme-file "hall")  (scheme-file "conmanv4")))))
