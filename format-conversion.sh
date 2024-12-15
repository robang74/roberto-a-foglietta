#!/bin/bash -e
#
# (C) Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#


if [ "$2" != "" ]; then
    for i in "$@"; do
        bash $0 "$i"
    done
else ###########################################################################

if [ -d "$1" ]; then
    cd "$1"
    echo
    echo "working path: $1 -> $PWD"
fi

echo
mkdir -p html

for i in *.md; do
    if [ "$i" == "README.md" ]; then
        continue
    fi
    echo "converting $i in html ..."
    f="html/${i%.md}.html"
    sed -e "s,^# \(.*\),<H1>\\1</H1>," $i > $f
    sed -i "s,^## \(.*\),<H2>\\1</H2>," $f
    sed -i "s,^### \(.*\),<H3>\\1</H3>," $f
    sed -i "s,^#### \(.*\),<H4>\\1</H4>," $f
    sed -i "s,^##### \(.*\),<H5>\\1</H5>," $f
    sed -i "s,^ *[-+\*] *> *\(.*\),<blockquote><li style='margin-left: 25px; text-indent: -25px;'>\\1</li></blockquote>," $f
    sed -i "s,^ *[-+\*] \(.*\),<li style='margin-left: 25px;  text-indent: -25px;'>\\1</li>," $f
    sed -i "s,^ *\([0-9]*\)\. \(.*\),<li style='margin-left: 25px;  text-indent: -25px; list-style-type: none;'><b>\\1.</b><span>\&nbsp;\&nbsp;\&nbsp;</span>\\2</li>," $f
    sed -i "s,\*\*\(.*\)\*\*,<b>\\1</b>,g" $f
    sed -i "s,\*\(.*\)\*,<i>\\1</i>,g" $f
    sed -i "s,\\\<\(.*\)\\\>,\&lt;\\1\&gt;,g" $f
    sed -i "s,^> \(.*\),<blockquote>\\1</blockquote>," $f
    sed -i 's,\[\([^]]*\)\](\([^)]*\)),<a href="\2">\1<\/a>,g' $f
    sed -i "s,^ *$,<p/>," $f
    sed -i "s,^---.*,<hr>," $f
done

echo
echo "redirecting html links ..."

for i in img/*.png img/*.jpg; do
    for j in html/*.html; do
        sed -i "s,\(src=\"\)$i,\\1../${i%.md},g" $j
        sed -i "s,\(href=\"\)$i,\\1../${i%.md},g" $j
    done
done

for i in *.md; do
    for j in html/*.html; do
        sed -i "s,\(href=\"\)$i\">$i,\\1${i%.md}.html\">${i%.md}.html,g" $j
    done
done

fi; exit #######################################################################
#
# PDF creation is ignored
#
################################################################################

mkdir -p pdf

echo
for i in *.md; do
    if [ "$i" == "README.md" ]; then
        continue
    fi
    echo "converting $i in pdf ..."
    cp -f $i pdf/$i.tmp
    for k in *.png *.md; do
        sed -i "s,\[.*\]($k),$k,g" pdf/$i.tmp
    done
    md2pdf pdf/$i.tmp pdf/${i%.md}.pdf
    rm -f pdf/$i.tmp
done

echo
echo "all done."
echo
exit

echo
echo "redirecting pdf link ..."

for i in *.png; do
    for j in pdf/*.pdf; do
        echo "reworking $j ..."
        rm -f $j.tmp
        pdftk $j output $j.tmp uncompress
        sed -i "s,\(/URI (file://\).*/$i,\\1../$i,g" $j.tmp
        pdftk $j.tmp output $j compress
        rm -f $j.tmp
    done
done

fi #############################################################################

