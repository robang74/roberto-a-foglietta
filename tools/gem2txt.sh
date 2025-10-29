#!/bin/bash

for if in "${1:-}"; do
if [ -n "${2:-}" ]; then
    of=$2;
else
    of=$(basename "$if")
    of=${of/.html/.txt}
    of=${of/.htm/.txt}
fi
html2text "$if" |\
sed   -e "s/^=\{79\}$//" -e 's/ \*\{4,5\}$/\n/' -e 's/^\*\{4,5\} /\n### /'     \
      -e 's/^ \{4\}\*/\n&/' -e 's/^ \{3\}[1-9]\. /\n&/' -e 's/\*\{3,5\} $/\n/' \
      -e 's/ \*\{3\}$/&\n/' -e 's/^\*\{3\} /\n&/' -e 's/^\[Icona .*/\n-- HO --\n\n&/' \
| sed -e 's/^\[Icona /\[Attachment: /' -e 's,^\*+$,,' \
> "$of"
grep -q "Esporta in Fogli" "$of" || sed -e 's,\.$,.\n' -i "$of"
declare -i n=$(grep -n "Norme_sulla_privacy_di_Google" "$of" | cut -d: -f1)
test $n -gt 0 && head -n$((n-1)) "$of" >"$of.tmp" && mv -f "$of.tmp" "$of"
done
