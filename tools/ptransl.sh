#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#

link="https://raw-githubusercontent-com.translate.goog/robang74/roberto-a-foglietta/refs/heads/main"
lraw="https://raw.githubusercontent.com/robang74/roberto-a-foglietta/refs/heads/main"

if [ "x$1" == "x-s" ]; then
    ch1='' 
    ch2=''
    shift
else
    ch1='[' 
    ch2=']'
    
fi
test -f "$1" || exit $?; md=$1
test -n "$ch1" &&
    echo '[(**`raw`**)]'"(${lraw}/$md)"

lg=it
LG=IT
echo "${ch1}[**\`${LG}\`**](${link}/${md}?_x_tr_sl=en&_x_tr_tl=${lg}&_x_tr_hl=${lg}-${LG}&_x_tr_pto=wapp)${ch2}"
for lg in en de fr es; do
LG=$(echo $lg | tr [a-z] [A-Z])
echo "${ch1}[**\`${LG}\`**](${link}/${md}?_x_tr_sl=it&_x_tr_tl=${lg}&_x_tr_hl=${lg}-${LG}&_x_tr_pto=wapp)${ch2}"
done
