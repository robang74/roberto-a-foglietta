#!/bin/bash

function get_tables_lines() {
    test -r "$1" || return 1
    grep -ne "^|.*|" $1 | cut -d: -f1
}

function find_first_table() {
    declare -i l s=$1 n=$1
    test $n -gt 0 || return 1
    for l in $@; do
        test $l -eq $n || break
        let n++
    done
    let n--
    local lines=$(echo $@ | sed -e "s,.* $n,,")
    echo "n=$n;s=$s:l=$l:$lines" >&2
    echo "$s:$n:$lines"
}

function find_all_tables() {
    declare -i t=1
    local range lines=$@
    while [ -n "$lines" ]; do
        range=$(find_first_table $lines)
        echo "table #$t found in ${range%:*}"
        let t++
        lines=$(echo ${range##*:})
        echo "range '$lines'"
    done
}

function file_conv_one_table() {
    declare -i n t=$1 a=$2 b=$3
    local idstrn f=$4

    let a--
    n=$(wc -l $f | cut -d' ' -f1)

    idstrn=$(printf "table-%03d" $t)
    echo "converting table in file at $a:$b"
    if [ $n -gt 0 ]; then
        head -n$a $f
        printf "<div class='center'><table id='$idstrn'>"
        head -n$b $f | tail -n$[b-a] |\
            sed -e "s, *|,<tr><td>,"   \
                -e "s,| *$,</td></tr>," \
                -e "s,|,</td><td>,g" \
                -e "s,_,\&nbsp;,g"
        printf "</table></div>"
        tail $f -n$[n-b]
    fi > $f.tmp
    mv -f $f.tmp $f
    sed -e "s,  *</td>, </td>,g" \
        -e "s,<td>[ -]\+</td>,<td></td>,g" \
        -e "s,<tr>\(\(<td></td>\)*\)</tr>,<tr class='trline'>\\1</tr>," \
        -e "/<table id='table-[0-9]\{3\}'>/s,<\(/*\)td>,<\\1th>,g" \
        -e "s,<tr><td>,<tr><td class='td1stcol'>," \
        -i $f
}

function file_conv_all_table() {
    declare -i t=1
    local f=$1; shift
    local range lines=$@
    while [ -n "$lines" ]; do
        range=$(find_first_table $lines)
        echo "table found in $range -> "${range%:*} >&2
        file_conv_one_table $t $(echo "${range%:*}" | tr : ' ') $f
        lines=$(echo ${range##*:})
        let t++
    done
    sed -e "s,^</*table[^>]*>,&\\n," -i $f
}

for f in ${@:-html/*.html}; do
    lines=$(get_tables_lines $f)
    test -n "$lines" || continue
    echo
    echo "converting table in file: $f"
    echo "tables: "${lines:-none} >&2
    file_conv_all_table $f $lines
done
echo
