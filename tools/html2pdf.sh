#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#

opt="--enable-local-file-access"
css=0
for i in "$@"; do
    case $1 in
    "-g") opt="-g $opt"
        shift
        ;;
    "-w") echo "@import url('pdfwarm.css');" > html/custom.css
        css=1
        shift
        ;;
    "-c") echo "@import url('pdfcool.css');" > html/custom.css
        css=1
        shift
        ;;
    "-b") printf "" > html/custom.css
        css=1
        shift
        ;;
       *) break
        ;;
    esac
    shift
done

# set the CSS by default
if [ "$css" == "0" ]; then
    echo "@import url('pdfcool.css');" > html/custom.css
fi

echo
for f in ${@:-html/*.html}; do
    test -r "$f" || continnue
    echo "converting in PDF file: $f"
    wkhtmltopdf -ql $opt $f ${f%.html}.pdf
    echo
done

mkdir -p pdf
mv html/*.pdf pdf
