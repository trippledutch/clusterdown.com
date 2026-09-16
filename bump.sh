#!/bin/sh
# Zet de inhoudshash van de gedeelde stylesheets/scripts achter de
# verwijzingen in de HTML. Zo haalt de browser een gewijzigd bestand altijd
# opnieuw op (nginx cachet /huisstijl/*.css en *.js een jaar lang als
# "immutable"), en hoeft niemand te weten dat hij hard moet verversen.
cd "$(dirname "$0")" || exit 1
pagina=$(md5 -q huisstijl/pagina.css | cut -c1-8)
paginajs=$(md5 -q huisstijl/pagina.js | cut -c1-8)
ct=$(md5 -q huisstijl/clustertriage.css | cut -c1-8)
ct2=$(md5 -q huisstijl/clustertriage-v2.css | cut -c1-8)
storing=$(md5 -q huisstijl/storing.css | cut -c1-8)
fav=$(md5 -q favicon.png | cut -c1-8)
consent=$(md5 -q huisstijl/consent.js | cut -c1-8)
for f in $(find . -name "*.html" -not -path "./.git/*"); do
  perl -0pi -e "s{(huisstijl/pagina\.js)(\?v=[0-9a-f]+)?}{\$1?v=$paginajs}g; \
                s{(huisstijl/pagina\.css)(\?v=[0-9a-f]+)?}{\$1?v=$pagina}g; \
                s{(huisstijl/clustertriage-v2\.css)(\?v=[0-9a-f]+)?}{\$1?v=$ct2}g; \
                s{(huisstijl/clustertriage\.css)(\?v=[0-9a-f]+)?}{\$1?v=$ct}g; \
                s{(huisstijl/storing\.css)(\?v=[0-9a-f]+)?}{\$1?v=$storing}g; \
                s{(favicon\.png)(\?v=[0-9a-f]+)?}{\$1?v=$fav}g; \
                s{(huisstijl/consent\.js)(\?v=[0-9a-f]+)?}{\$1?v=$consent}g" "$f"
done
echo "consent.js=$consent favicon.png=$fav pagina.css=$pagina pagina.js=$paginajs clustertriage.css=$ct clustertriage-v2.css=$ct2 storing.css=$storing"
