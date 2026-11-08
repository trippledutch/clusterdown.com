#!/usr/bin/env python3
"""
Ping IndexNow for the pages that changed in a push. Meant for the
post-receive hook on the server, after the checkout has been updated:

    python3 tools/indexnow-changed.py            # reads "old new ref" lines on stdin
    python3 tools/indexnow-changed.py OLD NEW    # or name the two commits yourself
    python3 tools/indexnow-changed.py OLD NEW --dry-run

Only pages that are in site/sitemap.xml are submitted, so drafts, assets and
deleted pages are skipped. A change to a shared file (CSS, JS, images) does
not count as a page change. The host and key come from the sitemap and the
key file in site/, so the same script works for clustertriage.com and
clusterdown.com. Never fatal: a failed ping prints a line and exits 0, so
it can never break a deploy.
"""
import json
import re
import subprocess
import sys
import urllib.request
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SITE = REPO / 'site'
ZERO = '0' * 40


def changed_files(old, new):
    if old == ZERO:  # first push of the branch: nothing to compare with
        return []
    out = subprocess.run(['git', 'diff', '--name-only', '--diff-filter=AMR', old, new, '--', 'site/'],
                         capture_output=True, text=True, cwd=REPO, check=False).stdout
    return [l for l in out.splitlines() if l]


def page_url(path, host):
    rel = path[len('site/'):]
    if rel.endswith('index.html'):
        return f'https://{host}/' + rel[:-len('index.html')]
    if rel.endswith('.html'):
        return f'https://{host}/' + rel
    return None


def main(argv):
    dry = '--dry-run' in argv
    args = [a for a in argv if a != '--dry-run']
    if len(args) >= 2:
        pairs = [(args[0], args[1])]
    else:
        pairs = []
        for line in sys.stdin:
            parts = line.split()
            if len(parts) == 3 and parts[2] == 'refs/heads/main':
                pairs.append((parts[0], parts[1]))
    sitemap = (SITE / 'sitemap.xml').read_text(encoding='utf-8')
    locs = set(re.findall(r'<loc>([^<]+)</loc>', sitemap))
    host = re.search(r'<loc>https://([^/<]+)/', sitemap).group(1)
    key = next((p.stem for p in sorted(SITE.glob('*.txt'))
                if re.fullmatch(r'[0-9a-fA-F]{8,128}', p.stem)
                and p.read_text(encoding='utf-8').strip() == p.stem), None)
    urls = []
    for old, new in pairs:
        for f in changed_files(old, new):
            u = page_url(f, host)
            if u in locs and u not in urls:
                urls.append(u)
    if not urls:
        print('IndexNow: no changed pages to submit')
        return 0
    if not key:
        print('IndexNow: no key file in site/, skipped')
        return 0
    print(f'IndexNow: {len(urls)} changed page(s) on {host}')
    for u in urls:
        print('  ' + u)
    if dry:
        print('IndexNow: dry run, nothing sent')
        return 0
    data = json.dumps({'host': host, 'key': key, 'keyLocation': f'https://{host}/{key}.txt',
                       'urlList': urls}).encode()
    req = urllib.request.Request('https://api.indexnow.org/IndexNow', data=data, method='POST',
                                 headers={'Content-Type': 'application/json; charset=utf-8'})
    try:
        r = urllib.request.urlopen(req, timeout=15)
        print(f'IndexNow: submitted, HTTP {r.status}')
    except Exception as e:
        print(f'IndexNow: ping failed ({e}); deploy is not affected')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
