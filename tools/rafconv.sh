#!/bin/bash -e

dwnload=0
mdtempl="template.md"

if [ "x$1" == "x-d" ]; then
    dwnload=1
    shift
fi

f="$1"
test -r "$f" || exit 1
f=$(echo "$f" | sed -e "s, ,,g" -e "s,^-*,,")
f=$(echo "$f" | tr [A-Z_àèéìòù] [a-z-aeeiou])
f=$(echo "$f" | sed -e "s,-[re]*v[0-9].md$,.md,")
echo
echo "> INFO   : working on $f"
command cp -i "$1" "$f" || exit $? && echo

################################################################################

function strfindline() {
    head -n20 $1 | grep --color=never -ne "$2" | head -n1 | cut -d: -f1
}

declare -i sl el fl
sl=$(strfindline $f "Roberto A. Foglietta")
el=$(strfindline $f "GNU/Linux Expert and Innovation Supporter")
fl=$(cat $f | wc -l)
let sl--

#echo "> DEBUG  : sl=$sl, el=$el, fl=$fl"

head -n$sl $f > $f.tmp
tac $f | head -n$[fl-el] | tac >> $f.tmp

sl=$(strfindline $f.tmp 'Published [A-Za-z]* [0-9]*, [0-9]*')
el=$(tail $f | grep -nie "Share alike" -e "Copyright" | head -n1 | cut -d: -f1)
fl=$(cat $f.tmp | wc -l)
let fl-=sl el=10-el+2

#echo "> DEBUG  : sl=$sl, el=$el, fl=$fl"

head -2 $mdtempl > $f
head -n$[sl-2] $f.tmp >> $f
str1=$(grep -e 'Published [A-Za-z]* [0-9]*, [0-9]*' $f.tmp)
str2=$(grep -e 'Published ${PUBLISH_DATE}*' $mdtempl | cut -d- -f2-)
echo "$str1 -$str2" >> $f
tac $f.tmp | head -n$fl | tac | head -n$[fl-el] >> $f
tail -8 $mdtempl >> $f

rm -f $f.tmp
sed -e "s,\([^\[(]\)\(lnkd.in/[^ ]\{8\}\),\\1[\\2](\\2),g" \
    -e "s,^### *.*,---\n\n&," -i $f

################################################################################

cmd1="tools/format.sh"
cmd2="$(dirname $0)/format.sh"
for cmd in ${cmd2} ${cmd2}; do
    if [ -r "$cmd" ]; then
        echo "> INFO   : formatting markdown..."
        source "$cmd" $f
        break
    fi
done

################################################################################

link="https://web-api.textin.com/ocr_image/external/"
list=$(sed -ne "s,.*\($link.*\)).*,\\1,p" $f)
test -n "$list" && \
echo ">        : remote image found $(echo "$list" | wc -l)"

hifn="${f%.md}-img"
declare -i n=1
for i in $list; do
    ifn=${hifn}-$(printf "%03d" $n).${i##*.}
    if [ $dwnload -eq 1 ]; then
        echo "> INFO   : downloading img/$ifn ..."
        if which wget >/dev/null; then
            wget -q "$i" -O img/$ifn
        else
            curl -Ss "$i" -o img/$ifn
        fi   
    fi
    sed -e "s,$link.*${i##*/}),img/$ifn)," -i $f
    let n++
done
echo "> DONE."
echo

