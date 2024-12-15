## ZIP ARCHIVES

[**`EN`**] These `zip` archives are incremental. Each one contains updates and additions to the previous one. So they all have to be expanded in the same folder to get the complete website of all articles converted to `markdown` and then to `html` in this repository. To access the list of all articles, open the `index.html` file with the browser and in the `index` section you will find the list of all converted articles.

[**`IT`**] Questi archivi `zip` sono incrementali. Ognuno di essi contiene gli aggiornamenti e le aggiunte rispetto al precedente. Quindi devono essere espansi tutti quanti nella stessa cartella per ottenere il sito web completo di tutti gli articoli convertiti in `markdown` e poi in `html` di questo repositori. Per accedere all'elenco di tutti gli articoli aprire con il browser il file `index.html` e nella sezione `index` troverete la lista di tutti gli articoli convertiti.

### Example

```
mkdir -p archivio-html
for i in $(ls -1v archivio-html-*.zip); do 
    unzip -o $i -d archivio-html
done
```
