#! /bin/bash
export LC_ALL="C"
guile -L . -e main -s "./conmanv5/cemail.scm" "a"
