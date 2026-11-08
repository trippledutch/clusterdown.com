# clusterdown.com

Static website of ClusterDown, the incident-triage entry point of ClusterTriage,
in Dutch (`/nl/`) and English (`/en/`).

## Layout

| Path | What |
|---|---|
| `site/` | Everything that is served. This directory is the nginx web root on the server. |
| `site/nl/`, `site/en/` | The pages, one directory per URL, `index.html` inside. |
| `site/styles/` | Shared stylesheets (copies of clustertriage.com's), `consent.js` (cookie banner + Consent Mode) and the IBM Plex fonts. |
| `tools/` | Maintenance scripts. Not served. |
| `docs/` | Repository documentation. Not served. |

## Tools

- `sh tools/bump.sh` stamps content hashes on the stylesheet, script and
  favicon references. Run it after changing anything in `site/styles/` or the
  favicon; nginx caches those files for a year.
- `python3 tools/indexnow-changed.py` pings IndexNow for the pages that changed
  in a push (only URLs in the sitemap). It runs from the server's post-receive
  hook; `python3 tools/indexnow-changed.py OLD NEW --dry-run` shows what it would send.

## Deploy

`main` is the only branch. The server checkout at `/var/www/clusterdown.com`
updates itself on push:

    git push production main

nginx serves `/var/www/clusterdown.com/site`.

After the checkout updates, the post-receive hook runs
`python3 tools/indexnow-changed.py`, which pings IndexNow for the changed pages.
It never fails the push.

## Wording

Same rules as clustertriage.com: no "health check", no em dashes, nothing from
the CloudLabs era reused verbatim.
