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
    ch1='' 
    ch2=''
    shift
else
    ch1='[' 
    ch2=']'
    
fi
test -f "$1" || exit $?; md=$1

function mainfunc() {
    local lg=it LG=IT
    echo "${ch1}[**\`${LG}\`**](${link}/${md}?_x_tr_sl=en&_x_tr_tl=${lg}&_x_tr_hl=${lg}-${LG}&_x_tr_pto=wapp)${ch2}"
    for lg in en de fr es; do
        LG=$(echo $lg | tr [a-z] [A-Z])
        echo "${ch1}[**\`${LG}\`**](${link}/${md}?_x_tr_sl=it&_x_tr_tl=${lg}&_x_tr_hl=${lg}-${LG}&_x_tr_pto=wapp)${ch2}"
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
    echo $y-$n-$d
}



if [ -n "$ch1" ]; then
    echo
    title=$(head $md | sed -ne 's,^#  *\(.*\),\1,p' -e 's,^##  *\(.*\),\1,p' | head -n1)
    pdate=$(sed -ne "s,^Published \([^-]*\) .*,\\1,p" $md)
    pdate=$(getdate "$pdate")
    nnn=$(echo $md | cut -d- -f1)
    printf "* ${nnn} - ${PUBLISH_DATE:-${pdate:-PUBLISH_DATE}} - ";
    printf '([**`raw`**]'"(${lraw}/$md))" 
    mainfunc | tr -d '\n'
    echo "- [${title:-\$TITLE}]($md)"
    echo
else
    mainfunc
fi
