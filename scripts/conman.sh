#! /bin/bash
export LC_ALL="C"
export GUILE_LOAD_PATH=guileloadpath
export GUILE_LOAD_COMPILED_PATH=guileloadcompiledpath
#cd $1
guileexecutable -L . -L /gnu/store/5yvzilh78996627i8avq532sl2c03i95-gnutls-3.6.15/share/guile/site/3.0 -e '(conmanv4)' -s conmanstorepath/share/guile/site/3.0/conmanv4.scm $1

