#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#

function md2htmlfunc() {
    local str=$(basename ${2%.html}) dir="html/";
    test "$str" = "index" || dir=""
    echo -n "<html>
    <head>
        <title>${str//-/ }</title>
        <link rel='stylesheet' href='${dir}default.css'>
        <link rel='stylesheet' href='${dir}custom.css'>
    </head>
    <body>
" >$2
    sed -e "s,@,\&commat;,g" -e "s,°,\&deg;,g" \
-e "s,^# \(.*\),<H1>\\1</H1>," \
-e "s,^## \(.*\),<H2>\\1</H2>," \
-e "s,^### \(.*\),<H3>\\1</H3>," \
-e "s,^#### \(.*\),<H4>\\1</H4>," \
-e "s,^##### \(.*\),<H5>\\1</H5>," \
-e "s,\(<div id=.firstdiv.\) .*>,\\1>," \
-e "s,^ *[-+\*] *> *\(.*\),<ul class='dqt'><li class='dqt'><blockquote class='dqt'>\\1</blockquote></li></ul>," \
-e "s,^> \(.*\),<blockquote>\\1</blockquote>," \
-e "s,^ *[-+\*] \(.*\),<li>\\1</li>," \
-e "s,^ *\([0-9]*\)\. \(.*\),<li style='list-style-type: none;'><b>\\1.</b><span>\&nbsp;\&nbsp;\&nbsp;</span>\\2</li>," \
-e 's,\[\([^]]*\)\](\([^)]*\)),<a href="\2">\1<\/a>,g' \
-e "s,\\\<\(.*\)\\\>,\&lt;\\1\&gt;,g" \
-e "s,^ *$,<p/>," -e "s,^---.*,<hr>," $1 | tr '\n' '@' >> $2
    while true; do
        str=$(sed -ne 's,\*\*,<b>,' -e 's,\*\*,</b>,p' $2);
        if [ -n "$str" ]; then
            sed -e 's,\*\*,<b>,' -e 's,\*\*,</b>,' -i $2
        else
            break
        fi
    done
    while true; do
        str=$(sed -ne 's,\*,<i>,' -e 's,\*,</i>,p' $2);
        if [ -n "$str" ]; then
            sed -e 's,\*,<i>,' -e 's,\*,</i>,' -i $2
        else
            break
        fi
    done
    while true; do
        str=$(sed -ne 's,`,<tt>,' -e 's,`,</tt>,p' $2);
        if [ -n "$str" ]; then
            sed -e 's,`,<tt>,' -e 's,`,</tt>,' -i $2
        else
            break
        fi
    done
    sed -e 's,</blockquote>\(@*\)<blockquote>,<br/>,g' \
        -e 's,<blockquote>\(@*\)</blockquote>,<br/>,g' -i $2
    str=$(cat $2 | tr '@' '\n')
    echo "$str
    </body>
</html>" > $2
    
}

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
rm -f html/[0-9]*.html

for i in *.md; do
    if [ "$i" == "README.md" ]; then
       echo "converting $i in index.html ..."
       md2htmlfunc "$i" index.html
       continue
    fi
    echo "converting $i in html ..."
    md2htmlfunc "$i" "html/${i%.md}.html"
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

sed -e 's,href="\([^h][^"]*\).md",href="html/\1.html",g' \
    -e "s,href='\([^h][^']*\).md',href='html/\\1.html',g" -i index.html

zipfle=archivio-html.zip
rm -f $zipfle
if [ "x$1" == "x-z" ]; then
    zip -r $zipfle img/ html/*.html html/*.css index.html -x $0
    zip -j $zipfle zip/README.md
    du -sk $zipfle
    echo
fi

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

