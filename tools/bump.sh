#!/bin/sh
# Stamps the content hash of the shared stylesheets, consent script and favicon
# into every page (?v=<hash>). nginx serves /styles/*.css, *.js and images as
# immutable for a year, so without the stamp a changed file would not reach
# returning visitors. Run after editing anything in site/styles or the
# favicon; commit the result. Usage: sh tools/bump.sh
cd "$(dirname "$0")/../site" || exit 1
site=$(md5 -q styles/site.css | cut -c1-8)
ct=$(md5 -q styles/clustertriage.css | cut -c1-8)
ct2=$(md5 -q styles/clustertriage-v2.css | cut -c1-8)
incident=$(md5 -q styles/incident.css | cut -c1-8)
consent=$(md5 -q styles/consent.js | cut -c1-8)
fav=$(md5 -q favicon.png | cut -c1-8)
for f in $(find . -name "*.html"); do
  [ -f "$f" ] || continue
  perl -0pi -e "s{(styles/site\.css)(\?v=[0-9a-f]+)?}{\$1?v=$site}g; \
                s{(styles/clustertriage-v2\.css)(\?v=[0-9a-f]+)?}{\$1?v=$ct2}g; \
                s{(styles/clustertriage\.css)(\?v=[0-9a-f]+)?}{\$1?v=$ct}g; \
                s{(styles/incident\.css)(\?v=[0-9a-f]+)?}{\$1?v=$incident}g; \
                s{(styles/consent\.js)(\?v=[0-9a-f]+)?}{\$1?v=$consent}g; \
                s{(favicon\.png)(\?v=[0-9a-f]+)?}{\$1?v=$fav}g" "$f"
done
echo "site.css=$site clustertriage.css=$ct clustertriage-v2.css=$ct2 incident.css=$incident consent.js=$consent favicon.png=$fav"
