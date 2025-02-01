#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#
################################################################################

export pdfres=216

export gsopts="-q 
-dBATCH
-dNOPAUSE
-dCompatibilityLevel=1.4
-dPDFACompatibilityPolicy=1
-dCompressFonts=true
-dEmbedAllFonts=false
-dSubsetFonts=true
-dPDFSETTINGS=/ebook
-dDetectDuplicateImages
-dColorConversionStrategy=/sRGB
-dColorImageDownsampleType=/Bicubic
-dColorImageDownsampleThreshold=1.0
-dGrayImageDownsampleThreshold=1.0
-dMonoImageDownsampleThreshold=1.0
-dPreserveOverprintSettings=false
-dPreserveOPIComments=false 
-dPreserveEPSInfo=false
-dUCRandBGInfo=/Remove
-dFitPage
-r$pdfres
"

origimg="
-dDownsampleColorImages=false
-dDownsampleGrayImages=false
-dDownsampleMonoImages=false
-dAutoFilterGrayImages=false
"

sameres="
-dDownsampleColorImages=true
-dDownsampleGrayImages=true
-dDownsampleMonoImages=true
-dColorImageResolution=$pdfres
-dGrayImageResolution=$pdfres
-dMonoImageResolution=$pdfres
-dColorImageDownsampleThreshold=1.0
-dGrayImageDownsampleThreshold=1.0
-dMonoImageDownsampleThreshold=1.0
"

pdf_shrink_ltr() { pdf_shrink "letter" "$@"; }
pdf_shrink_lgl() { pdf_shrink "legal" "$@"; }
pdf_shrink_a4()  { pdf_shrink "a4" "$@"; }

pdf_shrink()
{ 
    local f ff fff sz
    case "$1" in
        a4|letter|legal) sz="$1"; shift
            ;;
        *) sz="a4"
            ;;
    esac
    echo
    for i in "$@"; do
        test -r "$1" || return 1;
        echo -n "PDF shrinking '$(basename "$1")' from $(du -ks "$1" | cut -f1) Kb to ...";
        f=${1//.ps/.pdf};
        tmpf=/tmp/${f##*/}
        ps2pdf14 "$1" "$tmpf"
        echo -n " $(du -ks "$tmpf" | cut -f1) Kb ...";
        ff=${f//.pdf/-shrinked.pdf};
        ps2pdf14 -sPAPERSIZE=${sz} $gsopts "$tmpf" "$ff";
        rm -f "$tmpf"
        if true; then
            echo " $(du -ks "$ff" | cut -f1) Kb";
        else
            echo -n " $(du -ks "$ff" | cut -f1) Kb ...";
            fff=${ff//-shrinked.pdf/-reduced.pdf}
            ps2pdf14 "$ff" "$fff"
            echo " $(du -ks "$fff" | cut -f1) Kb";
        fi
        shift
    done
    echo
}
export -f pdf_shrink

pdf_shrink "$@"

