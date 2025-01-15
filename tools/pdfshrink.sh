#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#
################################################################################

function pdfshrink() {
	test -r "$1" || return 1
	echo -n "PDF shrinking '$(basename "$1")' from $(du -ks "$1" | cut -f1) Kb to ..."
	f=${1//.ps/.pdf};
	f=${f//.pdf/-shrinked.pdf};
	ps2pdf14 -sPAPERSIZE=a4 -dPDFFitPage -dPDFSETTINGS=/ebook "$1" "$f"
#	ps2pdf14 -sPAPERSIZE=a4 -dPDFFitPage -dPDFSETTINGS=/printer "$1" "$f"
#	ps2pdf14 -sPAPERSIZE=a4 -dPDFFitPage -dPDFSETTINGS=/prepress "$1" "$f"
	echo " $(du -ks "$f" | cut -f1) Kb"
	mv -f "$f" "${2:-$1}"
}
export -f pdfshrink

pdfshrink "$@"

