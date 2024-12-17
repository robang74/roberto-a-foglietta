#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#
md=$1
test -f "$md" || exit $?
lg=it
LG=IT
link=https://raw-githubusercontent-com.translate.goog/robang74/roberto-a-foglietta/refs/heads/main
echo "[[**\`${LG}\`**](${link}/${md}?_x_tr_sl=en&_x_tr_tl=${lg}&_x_tr_hl=${lg}-${LG}&_x_tr_pto=wapp)]"
for lg in en de fr es; do
LG=$(echo $lg | tr [a-z] [A-Z])
echo "[[**\`${LG}\`**](${link}/${md}?_x_tr_sl=it&_x_tr_tl=${lg}&_x_tr_hl=${lg}-${LG}&_x_tr_pto=wapp)]"
done
