#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#

opt="--enable-local-file-access"
css=0
for i in "$@"; do
    case $1 in
    "-g") echo "@import url('pdfgray.css');" > html/ucustom.css
        opt="-g $opt"
        css=1
        shift
        ;;
    "-p") echo "@import url('bwprint.css');" > html/ucustom.css
        opt="-g $opt"
        css=1
        shift
        ;;
    "-c") echo "@import url('onpaper.css');" > html/ucustom.css
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
    echo "" > html/ucustom.css
fi

echo
index=""
test $# -eq 0 && index="index.html"
for f in ${@:-html/*.html} $index; do
    test -r "$f" || continnue
    echo "converting in PDF file $f"
    wkhtmltopdf -ql $opt $f ${f%.html}.pdf 2>/dev/null &
done
wait

mkdir -p pdf/
mv -f html/*.pdf index.pdf pdf/ 2>&1 | grep -v .
printf "\npdf folder size: %d Kb\n\n" $(du -ks pdf/ | cut -f1)

