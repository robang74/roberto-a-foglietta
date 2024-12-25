#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#

li_A="<li style='list-style-type: none;'><b>"
li_B=".</b><span>\&nbsp;\&nbsp;\&nbsp;</span>"
#li_B=".<span style='visibility: hidden;'>_</span></b>"

ul_A="<ul class='dqt'><li class='dqt'><blockquote class='dqt'>"
ul_B="</blockquote></li></ul>"

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
    local i str=$(basename ${2%.html}) dir=""
    test "$str" == "index" && dir="html/"

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
-e "s,^ *[-+\*] *> *\(.*\),${ul_A}\\1${ul_B}," \
-e "s,^> \(.*\),<blockquote>\\1</blockquote>," \
-e "s,^\( *\)[-+\*] \(.*\),\\1<li>\\2</li>," \
-e "s,^\( *\)\([0-9]*\)\. \(.*\),\\1${li_A}\\2${li_B}\\3</li>," \
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
    for i in 3 2 1; do
        let b=i*3 a=b-2 c=i+1; a=${a/1/2}; #echo "$i $a $b $c" >&2
        sed -e "s/ \{$a,$b\}<li\([ >]\)/<li class='li${c}in'\\1/" -i $2
    done
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

list=""
index=0
for i in ${@:-*.md}; do
    if [ "$i" == "template.md" ]; then
        continue
    elif [ "$i" == "README.md" ]; then
        index=1
        continue
    fi
    echo "converting $i in html ..."
    md2htmlfunc "$i" "html/${i%.md}.html"
    list="$list html/${i%.md}.html"
done

echo
echo "redirecting html links ..."

function get_images_list() {
    local dir ext
    for dir in "data/" "img/" ""; do
        for ext in jpg png; do
            ls -1 ${dir}*.${ext}
        done 2>/dev/null
    done
}

for j in $list; do
    for i in $(get_images_list); do
        sed -e "s,\(href=.\)$i,\\1../$i,g" \
            -e "s,\(src=.\)$i,\\1../$i,g" -i $j
    done
    for i in *.md; do
        sed -e "s,\(href=.\)$i\">$i,\\1${i%.md}.html\">${i%.md}.html,g" -i $j
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

echo
echo "converting md tables ..."
source tools/tabl2html.sh $list 2>/dev/null

zipfle="archivio-html.zip"
if [ "$zip" == "1" ]; then
    rm -f $zipfle
    zip -r $zipfle img/ html/*.html html/*.css index.html -x $0
    zip -j $zipfle zip/README.md
    du -sk $zipfle
    echo
fi

fi
