#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#
################################################################################

pagebody=$(sed -e "s,ucustom\.css,imgfunc.css,g" html/items/pagebody.htm |\
    grep -ive "<script" -ie "javascript")

dir="html/"

BODY_CONTENT="<style>body { max-width: 1600px; }</style>"
BODY_CONTENT+="<center><h2>Image Function Test Page</h2></center>"
BODY_CONTENT+=$(cat html/items/imgfunc.htm)
pagebody=$(eval echo "\"$pagebody\"")

funclist=$(sed -ne "s,img.\([^ ]*\) { .*,\\1,p" html/imgfunc.css |\
    grep -v inverted | grep --color=never -n .)

declare -A func
eval $(echo "$funclist" | sed -e 's/\(.*\):\(.*\)/func[\1]="\2"/')

width="400px"
imgpath="${1:-img/warp-speed-jump.png}"
eval echo "\"$pagebody\"" >imgtest.html

source tools/tabl2html.sh imgtest.html
source alias.rc; c imgtest.html

