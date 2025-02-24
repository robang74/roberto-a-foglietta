#!/bin/bash -e
#
# (C) 2025, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#
################################################################################

ls -1 *.html > list.txt; 
n=$(wc -l list.txt | cut -d' ' -f1)
for i in $(seq 1 $n); do
    pn=$(head -n$i list.txt | tail -n1);
    echo -n $(grep 'class="published"' $pn | cut -d'<' -f-2);
    echo -n " &middot;&middot; <a href='${pn}' target='_blank'>$pn</a>";
    echo "</p>";
done > list.htm
sed -e "s,Published on ,,"  -e "s,[0-9]\{2\}:[0-9]\{2\},," \
    -e "s,<p ,<li ," -e "s,</p>,</li>," -i list.htm

pf() {
echo "<html><head><title>RAF on LinkedIn</title></head><body>"
echo "<div style='max-width: 800px; margin: auto; white-space: pre-wrap; text-align: justify;'>"
echo "<h1 align='center'>Roberto A. Foglietta on LinkedIn</h2>"
echo "<h2>List of the published articles</h2><hr>"
cat list.htm | sort -rn
echo "<hr>
<h2>Copyright notice<br><br><sup>&copy; 2024, <b>Roberto A. Foglietta</b> &lt;roberto.foglietta<span>@</span>gmail.com&gt;</sup></h2>
All the files in this gihub repository and the related website are published under the <b>Creative Commons Attribution Non-Commercial No-Derivatives 4.0 International</b> license terms (<a href='https://creativecommons.org/licenses/by-nc-nd/4.0/'>CC BY-NC-ND 4.0</a>), unless stated differently or not applicable due to a different and previous authorship.
<br>
Moreover, if a version of a document included in this repository exists or has existed under different licence terms, the licence terms of the latest version presented here apply. Even when the new licence terms are more restrictive, because permissions for any free content may be revoked at any time at the will of the author, and updating a licence to be more restrictive explicitly implies this will.
<br>
Finally, these licensing terms apply to the single document and to the entire collection as a collection, as well.
"
echo "<br></div><br></body></html>"
}

pf > index.htm
rm -f list.htm list.txt
