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

## Deploy

`main` is the only branch. The server checkout at `/var/www/clusterdown.com`
updates itself on push:

    git push production main

nginx serves `/var/www/clusterdown.com/site`.

## Wording

Same rules as clustertriage.com: no "health check", no em dashes, nothing from
the CloudLabs era reused verbatim.
