#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#
################################################################################

declare -i start_t=$(date +%s%N)

################################################################################

li_A="<li style='list-style-type: none;'><b>"
#li_B=".</b><span>\&nbsp;\&nbsp;\&nbsp;</span>"
#li_B=".<span style='visibility: hidden;'>_</span></b>"
li_B=".<span style='visibility: hidden;'>--</span></b>"

ul_A="<ul class='dqt'><li class='dqt'><blockquote class='dqt'>"
ul_B="</blockquote></li></ul>"

# RAF, 2024-12-26: the svg code has been taken by github to be used with github
warn_A='<span class="warnicon spanicon">&nbsp;<svg class="warnicon svgicon"'\
' viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true">'\
'<path d="M6.457 1.047c.659-1.234 2.427-1.234 3.086 0l6.082 11.378A1.75 1.75 0'\
' 0 1 14.082 15H1.918a1.75 1.75 0 0 1-1.543-2.575Zm1.763.707a.25.25 0 0 0-.44'\
' 0L1.698 13.132a.25.25 0 0 0 .22.368h12.164a.25.25 0 0 0 .22-.368Zm.53'\
' 3.996v2.5a.75.75 0 0 1-1.5 0v-2.5a.75.75 0 0 1 1.5 0ZM9 11a1 1 0 1 1-2 0 1'\
' 1 0 0 1 2 0Z"></path></svg><b>&nbsp;&nbsp;WARNING&nbsp;&nbsp;</b></span>'
warn_A=$(echo "$warn_A" | sed -e "s,\,,\\\,g" -e "s,\&,\\\&,g")

# RAF, 2024-12-26: the svg code has been taken by github to be used with github
info_A='<span class="infoicon spanicon">&nbsp;<svg class="infoicon svgicon"'\
' viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true">'\
'<path d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8Zm8-6.5a6.5 6.5 0 1 0 0 13 6.5 6.5'\
' 0 0 0 0-13ZM6.5 7.75A.75.75 0 0 1 7.25 7h1a.75.75 0 0 1 .75.75v2.75h.25a.75.75'\
' 0 0 1 0 1.5h-2a.75.75 0 0 1 0-1.5h.25v-2h-.25a.75.75 0 0 1-.75-.75ZM8 6a1 1 0 1'\
' 1 0-2 1 1 0 0 1 0 2Z"></path></svg><b>&nbsp;&nbsp;NOTICE&nbsp;&nbsp;</b></span>'
info_A=$(echo "$info_A" | sed -e "s,\,,\\\,g" -e "s,\&,\\\&,g")

################################################################################

TARGET_BLANK="target='_blank' rel='noopener noreferrer'"

function get_html_item_str() {
    if [ -r "$1" ]; then
        str=$(cat "$1" | tr \" \')
        eval echo \"$str\"
    fi
}

function mini_mdlinkconv() {
    local t=${TARGET_BLANK}
    sed -e "s,\([ []*\)\[\([^][]*\)\]\([^(]\),\\1\&lbrack;\\2\&rbrack;\\3,g;" \
        -e "s,\[\([^[]*\)](\([^)]*\)?target=_blank *),<a href=\"\\2\" $t>\\1</a>,g" \
        -e "s,\!\[\([^[]*\)](\([^)]*\)),<img src=\"\\2\" alt=\"\\1\">,g" \
        -e "s,\[\([^[]*\)](\([^)]*\)),<a href=\"\\2\">\\1</a>,g" "$@"
}

function full_mdlinkconv() {
    mini_mdlinkconv -e "s,\&lbrack;,[,g" -e "s,\&rbrack;,],g" "$@"
}

function md2htmlfunc() {
    local a b c i str=$(basename ${2%.html}) title dir=""
    test "$str" == "index" && dir="html/"
    title=${str/index/${PWD##*/}};
    #title=${str//-/ };

    echo -n "<!DOCTYPE html>
<html>
    <head>
        <title>${title}</title>
        <meta charset='UTF-8'>
        <link rel='stylesheet' href='${dir}default.css'>
        <link rel='stylesheet' href='${dir}custom.css'>
    </head>
    <body>
" >$2
    source tools/ptopbar.sh $1 >> $2
    if [ "$str" = "index" ]; then
        sed -e "s, - (\[...raw...\]([^)]*\.md)) , - ," $1
    else
        cat $1
    fi | full_mdlinkconv >>$2

    sed -e "s,@,\&commat;,g" \
-e "s,\[\!WARN\],$warn_A,g" -e "s,\[\!WARNING\],$warn_A,g" \
-e "s,\[\!NOTE\],$info_A,g" -e "s,\[\!INFO\],$info_A,g" \
-e "s,m\*rda,m\&astr;rda,g" -e "s,sh\*t,sh\&astr;t,g" \
-e "s,c\*zzo,c\&astr;zzo,g" -e "s,d\*ck,d\&astr;ck,g" \
-e 's,^ *!\[\([^]]*\)\](\([^)]*\)) *$,<center><img src="\2"><br/>\1</center>,' \
-e 's,!\[\([^]]*\)\](\([^)]*\)),<img src="\2" alt="\1">,g' \
-e 's,^# \(.*\),<H1 id="\1">\1</H1>,' \
-e 's,^## \(.*\),<H2 id="\1">\1</H2>,' \
-e 's,^### \(.*\),<H3 id="\1">\1</H3>,' \
-e "s,^#### \(.*\),<H4>\\1</H4>," \
-e "s,^##### \(.*\),<H5>\\1</H5>," \
-e "s,\(<div id=.firstdiv.\) .*>,\\1>," \
-e "s,^ *[-+\*] *> *\(.*\),${ul_A}\\1${ul_B}," \
-e "s,^> \(.*\),<blockquote>\\1</blockquote>," \
-e "s,^\( *\)[-+\*] \(.*\),\\1<li>\\2</li>," \
-e "s,^\( *\)\([0-9]*\)\. \(.*\),\\1${li_A}\\2${li_B}\\3</li>," \
-e "s,\\\<\(.*\)\\\>,\&lt;\\1\&gt;,g" \
-e "s,^ *$,<p/>," -e "s,^---.*,<hr>," -i $2

function fx() {
    local i strn find file=$1; shift
    for i in "$@"; do
        find=$(echo "$i" | sed -e 's/\([",$*()]\)/\\\1/g')
        strn=$(echo "$i" | tr 'A-Z ' 'a-z-' | tr -dc '0-9a-z-')
        sed -e "s,\(<H[1-3] id=.\)$find\(.>.*\),\\1$strn\\2," -i $file
    done
}
    eval fx "$2" $(sed -ne 's,<H[1-3] id=.\([^>]*\).>.*,"\1",p' $2)
    #echo "$2" >&2

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

    TOPLINK=$(get_html_item_str html/items/toplink.htm)
    get_html_item_str html/items/footnote.htm >> $2

    echo "<br/>
    </body>
</html>" >> $2

    sed -e 's,^\&copy; 202[4-9].*Roberto A. Foglietta.*\&lt;.*,<p>&</p>,' \
        -e "s/<a [^>]*href=.http[^>]*/& ${TARGET_BLANK}/g" -i $2
    for i in 3 2 1; do
        let b=i*3 a=b-2 c=i+1; a=${a/1/2}; #echo "$i $a $b $c" >&2
        sed -e "s/ \{$a,$b\}<\(li\|blockquote\|tt\)\([ >]\)"\
"/<\\1 class='li${c}in'\\2/" -i $2
    done
}

function get_images_list() {
    local dir ext
    for dir in "data/" "img/" ""; do
        for ext in jpg png pdf txt; do
            ls -1 ${dir}*.${ext}
        done 2>/dev/null
    done
}

function link_md2html() {
    local i="$1" f="$2" dir="" dim="../"
    if [ "$f" == "index.html" ]; then dir="html/"; dim=""; fi
    echo "$1" | grep -qe "^italian/" && dir="../italian/html/"
    local a="${dir}${i##*/}.html" b="${dim}${i##*/}.md"
#
#    3-rules link translation legenda
#
#    .md#tag?target -> html
#    .md -> .html
#    .md?target -> .md
#
    sed -e "s,\(href=[\"']\)$i\.md\(#[^>]*>\),\\1$a\\2,g" \
        -e "s,\(href=[\"']\)$i\.md\([ \"']*>\),\\1$a\\2,g" \
        -e "s,\(href=[\"']\)$i\.md\([^#>]* target=\),\\1$b\\2,g" \
        -i $f
}

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

function main_md2html() {
    local b=${2:-\`} a=${2:+}
    local i j list="" index=0

    printf "$a"
    for i in $1; do
        if [ "$i" == "template.md" ]; then
            continue
        elif [ "$i" == "README.md" -o "$i" == "index.html" ]; then
            index=1
            continue
        fi
        #echo "converting $i in html ..."
        md2htmlfunc "$i" "html/${i%.md}.html"
        list="$list html/${i%.md}.html"
    done
    if [ $index -ne 0 ]; then
        #printf .
        #echo "converting README.md in index.html ..."
        md2htmlfunc README.md index.html
    fi
    printf "$b"

    printf "$a"
    #echo "redirection $1 image links ..."
    for j in $list; do
        for i in $(get_images_list); do
            sed -e "s,\(href=.\)$i,\\1../$i,g" \
                -e "s,\(src=.\)$i,\\1../$i,g" -i $j
        done
#       for i in *.md; do
#           sed -e "s,\(href=.\)$i\">$i,\\1${i%.md}.html\">${i%.md}.html,g" -i $j
#       done
    done
    printf "$b" #2

    printf "$a"
    #echo "replacing $1 markdown links ..."
    if [ "${PWD##*/}" == "chatgpt-answered-prompts" ]; then
        index=0
    fi
    for i in $(ls -1 *.md italian/*.md 2>/dev/null); do
        i=${i%.md}
        test "$i" == "template" && continue
        for j in $list; do
            link_md2html $i $j
        done
        if [ $index -ne 0 ]; then
            link_md2html $i index.html
        fi
    done
    printf "$b" #3

    printf "$a"
    #echo "converting $1 markdown tables ..."
    source tools/tabl2html.sh $list 2>/dev/null >&2
    printf "$b" #4
}

################################################################################

mkdir -p html
#test -n "$1" || rm -f html/[0-9]*.html

flist=$(ls -1 ${@:-*.md})
declare -i n=$(echo "$flist" | wc -l)
echo
if [ $n -gt 1 ]; then
    let n*=4; str=$(seq 1 $n)
    str=$(printf ".%.0s" $str)
    printf "parallel working |$str|\n""work progression |"
    for i in $flist; do
        if [ "$i" == "test-page.md" ]; then
            ln -sf tools/test-page.md .
        fi
        main_md2html $i &
        sleep 0.1
    done
    wait
    echo '|'
else
    printf "converting ${1/index.html/README.md} "
    main_md2html $1 '.'
    printf " "
fi

let start_t=$(date +%s%N)-start_t
let start_t=(start_t+500000)/1000000
printf "done in %d.%03d ms\n\n" $[start_t/1000] $[start_t%1000]

zipfle="archivio-html.zip"
if [ "$zip" == "1" ]; then
    rm -f $zipfle
    zip -r $zipfle img/ html/*.html html/*.css index.html -x $0
    zip -j $zipfle zip/README.md
    du -sk $zipfle
    echo
fi
