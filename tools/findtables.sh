#!/bin/bash

function get_tables_lines() {
    test -r "$1" || return 1
    grep -ne "^|.*|" $1 | cut -d: -f1
}

function find_tables() {
    declare -i l s=$1 n=$1
    test $n -gt 0 || return 1
    for l in $@; do
        test $l -eq $n || break
        let n++
    done
    local lines=$(echo $@ | sed -e "s,.* $l,,")
    echo "$s:$l:$lines"
}

declare -i t=1
for i in "$@"; do
    echo
    echo "file: $i"
    lines=$(get_tables_lines $i)
    while [ -n "$lines" ]; do
        range=$(find_tables $lines)
        echo "table #$t found in ${range%:*}"
        let t++
        lines=$(echo ${range##*:})
        echo "range '$lines'"
    done
done
echo
