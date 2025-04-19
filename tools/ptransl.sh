#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#

gitusr="robang74"
gitprj="roberto-a-foglietta"
head="https://raw-githubusercontent"
tail="refs/heads/main"
body="${gitusr}/${gitprj}/${tail}"
ext="com"

link="${head}-${ext}.translate.goog/${body}"
lraw="${head/-/.}.${ext}/${body}"

if [ "x$1" == "x-s" ]; then
    flg='s'
    ch1='' 
    ch2=''
    shift
elif [ "x$1" == "x-i" ]; then # this is for the README index
    flg='i'
    ch1='['
    ch2=']'
    shift
else                          # this is for the single file
    flg=''
    ch1='[' 
    ch2=']'
fi
test -f "$1" || exit 1

md=$1 
ilg=${2,,}

function mainfunc() {
    local lg LG ilg=${1:-auto}
    for LG in IT EN DE FR ES ; do
        lg=${LG,,}
        test "$ilg" == "$lg" && continue
        echo "${ch1}[**\`${LG}\`**](${link}/${md}?_x_tr_sl=${ilg}&_x_tr_tl=${lg}&_x_tr_hl=${lg}-${LG}&_x_tr_pto=wapp)${ch2}"
    done
}

function getdate() {
    declare -i n=1
    str="$@"
    m=${str:0:3}
    d=$(echo ${str:4} | cut -d, -f1)
    y=$(echo ${str:4} | cut -d' ' -f2)
    for s in Jen Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec; do 
        test "$m" == "$s" && break; let n++; done
    printf "%03d-%02d-%02d" $y $n $d | grep -v -- "-00-00" || date "+%F"
}

if [ "$flg" == "i" ]; then
    echo
    title=$(head $md | sed -ne 's,^#  *\(.*\),\1,p' -e 's,^##  *\(.*\),\1,p' | head -n1)
    pdate=$(sed -ne "s,^[\* ]*Published *\([^-]*\) .*,\\1,p" $md)
    pdate=$(echo "$pdate" | sed -e "s,\(...\)[a-z]* \(.*\),\\1 \\2,")
    pdate=$(getdate "$pdate")
    nnn=$(echo $md | cut -d- -f1)
    printf "* ${nnn} - ${PUBLISH_DATE:-${pdate:-PUBLISH_DATE}} - ";
    printf '([**`raw`**]'"(${lraw}/$md)) " 
    mainfunc $ilg | tr '\n' ' '
    echo "- [${title:-\$TITLE}]($md)"
    echo
else
    mainfunc $ilg
fi
