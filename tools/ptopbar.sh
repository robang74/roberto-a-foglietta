#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#
################################################################################

function get_file_real_name() {
    local file="${1:-}"
    if [ "$file" == "test-page.md" ]; then
        ln -sf tools/test-page.md .
    elif [ "$file" == "index.html" ]; then
        file="README.md"
    fi
    echo "$file"
}

function print_transl_from_to() {
    echo "${gtlink}/${1}?_x_tr_sl=${2:-auto}&_x_tr_tl=${3}&_x_tr_hl=${3}-${4}"\
"&_x_tr_pto=wapp"
}

function print_topbar() {
    declare -A LANG_LINKS
    local str lg LG lang=${7:-auto} trsl=0 file=${6:-}

    if [ "$file" == "README.md" ]; then
        file="index.html"
    else
        file="html/${file%.md}"
    fi

    PUBLISH_UNIVDATE="${3:-$(date +%F)}"
    ALINK_CLASS="class='${LINE_SHADE} topbar'"

    ORIGIN_CODE=""
    PUBLISH_SOURCE="${4:-}"
    if [ -n "$PUBLISH_SOURCE" ]; then
        PUBLISH_LINK="${5:-}"
        ORIGIN_CODE=" ${LINE_DASH} origin:&nbsp; 
    <a $ALINK_CLASS href='${PUBLISH_LINK}'>${PUBLISH_SOURCE}</a>"
    fi

    declare -i skip=$lang
    test $skip -ne 0 && lang="auto"
    #echo "7: '$7', skip: '$kip', lang: '$lang'" >&2
    if [ -n "$file" -a "$skip" != "-99" ]; then
        lang=${lang,,}
        TRNSL_STRN=""
        for LG in IT EN DE FR ES; do
            let skip++; test $skip -gt 0 || continue; lg=${LG,,}
            if [ "$lang" != "$lg" ]; then
                TRNSL_STRN+="<a $ALINK_CLASS "
                str=$(print_transl_from_to "$file" $lang $lg $LG)
                TRNSL_STRN+="href='$str'>${LG}</a>"
                if [ "$LG" != "ES" ]; then TRNSL_STRN+=" ${MDOT_DASH} "; fi
                trsl=1
            fi
        done
    fi
    if [ "$trsl" == "1" ]; then
        TRNSL_STRN=" ${LINE_DASH} translate:&nbsp; ${TRNSL_STRN}"
    else
        TRNSL_STRN=""
    fi

    TOPBAR_STRING="<p/>
<div class='topbar ${LINE_SHADE} ${TEXT_SHADE}' translate='no'>"\
"&nbsp;${LINE_MARK} ${LINE_DASH} published:&nbsp; <b class='tpbrbold'>"\
"${PUBLISH_UNIVDATE}</b> ${REVISION_STRING}${ORIGIN_CODE}${TRNSL_STRN}"

    gotolist="1 2 3"
    if [ "$file" != "index.html" ]; then
        GOTO_LINKS[1,1]="../${GOTO_LINKS[1,1]}"
        GOTO_LINKS[1,2]=".&#x27F0;."
    fi

    TOPBAR_STRING+=" ${LINE_DASH} goto:&nbsp;"
    for i in $gotolist; do
        TOPBAR_STRING+=" <a $ALINK_CLASS href='${GOTO_LINKS[$i,1]}'"\
"$(test $i -ne 1 && printf target='_blank')>${GOTO_LINKS[$i,2]}</a>"
        if [ $i -lt 3 ]; then TOPBAR_STRING+=" ${MDOT_DASH}"; fi
    done
    echo "${TOPBAR_STRING}&nbsp;</div>"

}

function get_html_item_str() {
    if [ -r "$1" ]; then
        str=$(cat "$1" | tr \" \')
        eval echo \"$str\"
    fi
}

################################################################################

gitusr="robang74"
gitprj="${PWD##*/}"
weburl="https://${gitusr}.github.io"
gtlink="${weburl//./-}.translate.goog/${gitprj}"

color="gray"
if [ "$gitprj" == "chatgpt-answered-prompts" ]; then
    color="gren"
elif [ "$gitprj" == "roberto-a-foglietta" ]; then
    color="blue"
elif [ "$gitprj" == "chatbots-for-fun" ]; then
    color="warm"
fi

LINE_SHADE="tpbr${color}"
TEXT_SHADE="tpbrtext"
LINE_MARK="<b>&#9783;&thinsp;&Ropf;</b>"
LINE_DASH="&nbsp;&mdash;&nbsp;"
MDOT_DASH="&nbsp;<b>&middot;</b>&nbsp;"

REVISION_STRING=""
PUBLISH_UNIVDATE=""
PUBLISH_SOURCE=""
PUBLISH_LINK=""

declare -A PROJ_LINKS GOTO_LINKS

PROJ_LINKS[1,1]="../chatbots-for-fun/index.html"
PROJ_LINKS[1,2]="C4F"
PROJ_LINKS[2,1]="../roberto-a-foglietta/index.html"
PROJ_LINKS[2,2]="RAF"
PROJ_LINKS[3,1]="../chatgpt-answered-prompts/index.html"
PROJ_LINKS[3,2]="Q&A"

################################################################################

file=$(get_file_real_name "${1:-}")
test -r "$file" || exit 1

dir=""
test "$file" != "README.md" && \
    dir="../"

declare -i i n=2
for i in 1 2 3; do
    echo ${PROJ_LINKS[$i,1]} | grep -q $gitprj && continue
    GOTO_LINKS[$n,1]=${dir}${PROJ_LINKS[$i,1]}
    GOTO_LINKS[$n,2]=${PROJ_LINKS[$i,2]}
    let n++
done
GOTO_LINKS[1,1]="index.html#pages-index"
GOTO_LINKS[1,2]="&#x21b4;&hairsp;&#8505;&thinsp;&equiv;"

if grep -qie "^#\{1,3\} *index *$" README.md 2>/dev/null; then
    GOTO_LINKS[1,1]="index.html#index"
fi

################################################################################

c="created="
s="'\\1' '\\2' '\\3'"
eval set -- $(sed -ne \
    "s/<.* $c[\"']\([^:\"']*\):\([^:\"']*\):\{0,1\}\([^:\"']*\).*/$s/p" "$file")
#echo "1: '${1:-}', 2: '${2:-}', 3: '${3:-}'" >&2

date1st=""
declare -i DATETYPE=1 revnum=$[0${3:-}]
gitlog=$(command git log --follow --format=format:'%ci' \
    "${file/test-page.md/tools/test-page.md}")
revnum+=$(echo "$gitlog" | grep . | wc -l)
command git status -s "$file" | grep -q . && let revnum++

if [ $revnum -gt 0 ]; then
    REVISION_STRING=" ${LINE_DASH} revision: <b class='tpbrbold
'>${revnum}</b class='
'>"
fi 2>/dev/null

date1st=${1:-}
if [ ! -n "$date1st" ]; then
    let DATETYPE++
    date1st=$(echo "$gitlog" | tail -n1 | cut -d' ' -f1)
    if [ ! -n "$date1st" ]; then
        let DATETYPE++
        date1st=$(date +%F)
    fi
fi
date1st+=$(get_html_item_str html/items/datetype.htm)

print_topbar "" "" "$date1st" "" "" "$file" ${2:-}

