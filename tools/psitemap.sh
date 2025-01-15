#!/bin/bash -e
#
# (C) 2024, Roberto A. Foglietta <roberto.foglietta@gmail.com> - 3-clause BSD
#
################################################################################

function get_git_last_change_date() {
    command git log -n1 --follow --format=format:'%ci' $1 | cut -d' ' -f1
}

htmpage=index.html
prjname=${PWD##*/}
weburl="https://robang74.github.io/$prjname"
page_change_date=$(get_git_last_change_date $htmpage)

echo >&2
echo "$page_change_date - $htmpage" >&2

echo "<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">

    <url>
        <loc>${weburl}/index.html</loc>
        <lastmod>${page_change_date}</lastmod>
        <changefreq>weekly</changefreq>
        <priority>1.0</priority>
    </url>
" > sitemap.xml

declare -i n=1
for htmpage in html/*.html pdf.*/index.html ; do
    page_change_date=$(get_git_last_change_date $htmpage)
    test -n "$page_change_date" || continue
    echo "$page_change_date - $htmpage" >&2
    let n++
    echo "
    <url>
        <loc>${weburl}/${htmpage}</loc>
        <lastmod>${page_change_date}</lastmod>
        <changefreq>weekly</changefreq>
        <priority>0.8</priority>
    </url>"
done >> sitemap.xml
echo "</urlset>" >> sitemap.xml

echo "User-agent: *
Allow: /img/
Allow: /html/
Allow: /data/
Allow: /pdf.todo/
Allow: /pdf.done/
Allow: /index.html
Sitemap: /sitemap.xml" > robots.txt

if true; then
    echo "pages: $n"
    echo
    ls -1 sitemap.xml robots.txt;
    echo
fi >&2

