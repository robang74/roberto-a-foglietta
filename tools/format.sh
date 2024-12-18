#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#
for f in "$@"; do

    if [ -f $f.bak ]; then
        echo "> ERROR  : $f.bak exists, skipped."
        echo
        continue
    fi
    cp -a $f $f.bak
    echo "> INFO   : $f.bak created"

    sed -e 's,\(^##*\) *\(.\)\(.*\),\1 \2\L\3\E,' -i $f
    sed -e 's,?trk=article-ssr-frontend-pulse_little-text-block),),' -i $f

    sed -e 's,@,\&commat;,g' $f | tr '\n' '@' >$f.tmp
    sed -e 's,\([^@]\)@\([^@]\),\1 \2,g' $f.tmp | tr '@' '\n' >$f
    sed -e 's,\&commat;,@,g' -i $f; rm -f $f.tmp

    prex=$(sed -ne "s,\(.*\) translate \[.*\],\\1,p" $f)
    if [ -n "$prex" ]; then

        declare -i n=1
        TR_LIST=$(source ${0%/*}/ptransl.sh -s $f)
        for LG in IT EN DE FR ES; do
            grep -q "\[\*\*\`$LG\`\*\*\]" $f && break
            str=$(echo "$TR_LIST" | head -n$n | tail -n1)
            eval export ${LG}_TR=\'$str\'
            let n++
        done
        if [ $n -ne 6 ]; then
            echo "> WARNING: translations inception skipped."
            echo ">    file: $f"
            echo
            continue
        fi
        line=$(sed -ne "s,.* \(translate \[.*\]\),\\1,p" $f)
        line="$prex $(eval echo $line)"
        m=$(wc -l $f | cut -d' ' -f1)
        n=$(grep --color=never -n "translate \[.*\]" $f | cut -d: -f1)
        { head -n$[n-1] $f; echo "$line"; tail -n$[m-n] $f; } >$f.tmp
        mv -f $f.tmp $f
        echo "DONE   : $f"
        echo
    fi
done
