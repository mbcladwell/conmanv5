#! /bin/bash
export LC_ALL="C"
##export GUILE_LOAD_PATH=guileloadpath
##export GUILE_LOAD_COMPILED_PATH=guileloadcompiledpath
guileexecutable -e '(conmanv5)' -s conmanstorepath/share/guile/site/3.0/conmanv5.scm

