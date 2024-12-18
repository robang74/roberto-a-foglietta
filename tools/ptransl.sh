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
lraw="${head}.${ext}/${body}"

if [ "x$1" == "x-s" ]; then
    ch1='' 
    ch2=''
    shift
else
    ch1='[' 
    ch2=']'
    
fi
test -f "$1" || exit $?; md=$1
if [ -n "$ch1" ]; then
    title=$(head $md | sed -ne 's,^#  *\(.*\),\1,p' -e 's,^##  *\(.*\),\1,p' | head -n1)
    echo "[${title:-\$TITLE}]($md)"
    echo '([**`raw`**]'"(${lraw}/$md))"
fi
lg=it
LG=IT
echo "${ch1}[**\`${LG}\`**](${link}/${md}?_x_tr_sl=en&_x_tr_tl=${lg}&_x_tr_hl=${lg}-${LG}&_x_tr_pto=wapp)${ch2}"
for lg in en de fr es; do
LG=$(echo $lg | tr [a-z] [A-Z])
echo "${ch1}[**\`${LG}\`**](${link}/${md}?_x_tr_sl=it&_x_tr_tl=${lg}&_x_tr_hl=${lg}-${LG}&_x_tr_pto=wapp)${ch2}"
done
