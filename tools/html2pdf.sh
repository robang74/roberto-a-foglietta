#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#

function chrprint() {
    chromium-browser --run-all-compositor-stages-before-draw \
        --headless --disable-gpu --no-pdf-header-footer --print-to-pdf=$2 $1
}

function pdfshrink() {
    local ff pf=$1
    bash tools/pdfshrink.sh $pf
    ff=${pf%.pdf}
    ff+="-shrinked.pdf"
    mv -f $ff $pf
}

echo
index=""
test $# -eq 0 && index="index.html"
mkdir -p pdf/
for f in ${@:-html/*.html} $index; do
    test -r "$f" || continnue
    echo "converting in PDF file $f"
    pf=${f%.html}.pdf
    pf=pdf/${pf/html\//}
    rm -f $pf
    chrprint $f $pf
    pdfshrink $pf | grep --color=never .
    echo
done
printf "pdf folder size: %d Kb\n\n" $(du -ks pdf/ | cut -f1)

if false; then

################################################################################

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
    backup=$(cat html/ucustom.css)
    echo "@import url('print.css');" > html/ucustom.css
fi

echo
index=""
test $# -eq 0 && index="index.html"
for f in ${@:-html/*.html} $index; do
    test -r "$f" || continnue
    echo "converting in PDF file $f"
    pf=${f%.html}.pdf
    rm -f $pf
    wkhtmltopdf --no-outline --disable-external-links --disable-internal-links \
        --print-media-type -ql $opt $f $pf 2>/dev/null &
done
wait

if [ "$css" == "0" ]; then
    echo "$backup" > html/ucustom.css
fi

mkdir -p pdf/
mv -f html/*.pdf index.pdf pdf/ 2>&1 | grep -v .
printf "\npdf folder size: %d Kb\n\n" $(du -ks pdf/ | cut -f1)

fi

