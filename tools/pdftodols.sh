#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#
################################################################################

dir="../html/"
titleb="Roberto A. Foglietta"
m_weburl="https://github.com/robang74/roberto-a-foglietta/blob/main"
m_downld="https://raw.githubusercontent.com/robang74/roberto-a-foglietta/refs/heads/main"
backlk="https://robang74.github.io/roberto-a-foglietta/index.html"
target="target='_blank' rel='noopener noreferrer'"

function pdfdolist_main() {
    local pdfdir titleh weburl downld indexf tmpfle

    for pdfdir in pdf.todo pdf.done; do
        titleh="RAF $pdfdir folder"
        weburl="${m_weburl}/$pdfdir"
        downld="${m_downld}/$pdfdir"
        indexf="$pdfdir/index.html"
        tmpfle="$pdfdir/index.tmp"

{ cd $pdfdir; ls -1 *.pdf; } | sort > $tmpfle
sed -e "s,^.*$,<li>(<a href='$weburl/&' $target>\&hairsp;\&#128065;\&hairsp;</a>) \&middot;\&middot; \&#x21C3;<a href='${downld}/&' ${target}>\&#x1f4be;</a>\&#x21C2; \&middot;\&middot; &</li>," -i $tmpfle

echo "<!DOCTYPE html>
<html>
    <head>
        <title>${titleh}</title>
        <meta charset='UTF-8'>
        <link rel='stylesheet' href='${dir}default.css'>
        <link rel='stylesheet' href='${dir}custom.css'>
        <style>
        a { text-decoration: none; }
        </style>
    </head>
    <body>
        <div id='firstdiv' created=':-99' style='max-width: 800px; margin: auto; white-space: pre-wrap; text-align: justify;'>
            <h2 align='center'>${titleb}</h2><h3 align='center'>Index for <a href='${weburl}' ${target}>${pdfdir}</a> folder</h3><hr>"\
> $indexf
cat $tmpfle >> $indexf
    echo "<hr><center>Surf back to the website's <b><a href='${backlk}'>main</a></b> page or for the <b><a href='#'>top</a></b> of this page.</center>
        </div>
        <br/>
    </body>
</html>" >> $indexf

rm -f $tmpfle

done

}

pdfdolist_main

