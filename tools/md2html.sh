#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#

#function orig_mdlinkconv() {
#    sed -e "s,\([ []*\)\[\([^][]*\)\]\([^(]\),\\1\&lbrack;\\2\&rbrack;\\3,g;" \
#        -e "s,\[\([^[]*\)](\([^)]*\)),<a href='\\2'>\\1</a>,g" \
#        -e "s,\&lbrack;,[,g" -e "s,\&rbrack;,],g" "$@"
#}

function mini_mdlinkconv() {
    sed -e "s,\([ []*\)\[\([^][]*\)\]\([^(]\),\\1\&lbrack;\\2\&rbrack;\\3,g;" \
        -e "s,\[\([^[]*\)](\([^)]*\)),<a href=\"\\2\">\\1</a>,g" "$@"
}

function full_mdlinkconv() {
    mini_mdlinkconv -e "s,\&lbrack;,[,g" -e "s,\&rbrack;,],g" "$@"
}

function md2htmlfunc() {
    local str=$(basename ${2%.html}) dir="html/";
    test "$str" = "index" || dir=""
    echo -n "<!DOCTYPE html>
<html>
    <head>
        <title>${str//-/ }</title>
        <meta charset='UTF-8'>
        <link rel='stylesheet' href='${dir}default.css'>
        <link rel='stylesheet' href='${dir}custom.css'>
    </head>
    <body>
" >$2
    if [ "$str" = "index" ]; then
        sed -e "s, - (\[...raw...\]([^)]*\.md)) , - ," $1
    else
        cat $1
    fi | full_mdlinkconv >>$2
    sed -e "s,@,\&commat;,g" -e "s,°,\&deg;,g" \
-e "s,m\*rda,m\&astr;rda,g" -e "s,sh\*t,sh\&astr;t,g" \
-e "s,c\*zzo,c\&astr;zzo,g" -e "s,d\*ck,d\&astr;ck,g" \
-e 's,^ *!\[\([^]]*\)\](\([^)]*\)) *$,<div align="center"><img src="\2"><br/>\1</div>,' \
-e 's,!\[\([^]]*\)\](\([^)]*\)),<img src="\2" alt="\1">,g' \
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
-e "s,\\\<\(.*\)\\\>,\&lt;\\1\&gt;,g" \
-e "s,^ *$,<p/>," -e "s,^---.*,<hr>," -i $2

    tf=$2.tmp
    cat $2 | tr '\n' '@' >$tf
    while true; do
        str=$(sed -ne 's,\*\*,<b>,' -e 's,\*\*,</b>,p' $tf);
        if [ -n "$str" ]; then
            sed -e 's,\*\*,<b>,' -e 's,\*\*,</b>,' -i $tf
        else
            break
        fi
    done
    while true; do
        str=$(sed -ne 's,\*,<i>,' -e 's,\*,</i>,p' $tf);
        if [ -n "$str" ]; then
            sed -e 's,\*,<i>,' -e 's,\*,</i>,' -i $tf
        else
            break
        fi
    done
    while true; do
        str=$(sed -ne 's,`,<tt>,' -e 's,`,</tt>,p' $tf);
        if [ -n "$str" ]; then
            sed -e 's,`,<tt>,' -e 's,`,</tt>,' -i $tf
        else
            break
        fi
    done
    sed -e 's,</blockquote>\(@*\)<blockquote>,<br/>,g' \
        -e 's,<blockquote>\(@*\)</blockquote>,<br/>,g' -i $tf
    cat $tf | tr '@' '\n' >$2
    rm  $tf

    echo "
    </body>
</html>" >> $2

    sed -e "s/<a [^>]*href=.http[^>]*/& target='_blank'/g" -i $2
}

if [ "$2" != "" ]; then
    for i in "$@"; do
        bash $0 "$i"
    done
else ###########################################################################

zip=0
if [ -d "$1" ]; then
    cd "$1"
    echo
    echo "working path: $1 -> $PWD"
    shift
elif [ "x$1" == "x-z" ]; then
    zip=1
    shift
fi

echo
mkdir -p html
test -n "$1" || rm -f html/[0-9]*.html

for i in ${@:-*.md}; do
    if [ "$i" == "template.md" ]; then
        continue
    elif [ "$i" == "README.md" ]; then
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

function link_md2html() {
    local i=${1%.md} f="$2" dir=""
    test "$f" == "index.html" && dir="html/"
    sed -e "s,\(href=[\"']\)$i\.md\([\"']\),\\1${dir}$i.html\\2,g" -i $f
}

for i in *.md; do
    #i=${i%.md}
    #echo "$i" >&2
    test "$i" == "template.md" && continue
    for j in html/*.html index.html; do
        #sed -e "s,\(href=[\"']\)$i\.md\([\"']\),\\1$i.html\\2,g" -i $j
        link_md2html $i $j
    done
    #sed -e "s,\(href=[\"']\)$i\.md\([\"']\),\\1html/$i.html\\2,g" -i index.html
done

zipfle="archivio-html.zip"
if [ "$zip" == "1" ]; then
    rm -f $zipfle
    zip -r $zipfle img/ html/*.html html/*.css index.html -x $0
    zip -j $zipfle zip/README.md
    du -sk $zipfle
fi

echo
fi
