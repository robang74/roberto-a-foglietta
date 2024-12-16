#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#
md=$1
test -f "$md" || exit $?
for lg in en de fr es; do
LG=$(echo $lg | tr [a-z] [A-Z])
link=https://raw-githubusercontent-com.translate.goog/robang74/roberto-a-foglietta/refs/heads/main
echo "[[**\`${LG}\`**](${link}/${md}?_x_tr_sl=it&_x_tr_tl=${lg}&_x_tr_hl=${lg}-${LG}&_x_tr_pto=wapp)]"
done
