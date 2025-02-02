#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#
################################################################################

fcssf="../html/fonts.css"
mkdir -p fonts
cd fonts
for i in $(sed -ne "s,src: url(\(.*\)) .*,\\1,p" $fcssf); 
    do wget $i; done
