#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#

grep --color=never -n 'origin' *.md | grep -ve ':. Published ' | sed -ne "s,^\([^:]*:[0-9]*:\).*linkedin.com/pulse/\([^)]*\).*,\\1 \\2,p"
