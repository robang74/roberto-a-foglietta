#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#

opt="--enable-local-file-access"

for i in "$@"; do
    case $1 in
    "-g") opt="-g $opt"
        ;;
    "-w") echo "@import url('pdfwarm.css');" > custom.css
        ;;
    "-c") echo "@import url('pdfcool.css');" > custom.css
        ;;
       *) test -r "$1" || exit 1; htm=$1; break
        ;;
    esac
    shift
done

test -r "$htm" && \
    wkhtmltopdf -ql $opt $htm ${htm%.html}.pdf
