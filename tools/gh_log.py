"""Actions run log indir (stdlib only). Kullanim:
  GITHUB_TOKEN=... uv run python tools/gh_log.py --run 38139884723
"""
import argparse, os, sys, urllib.request, urllib.error, zipfile, io

def get(url, token):
    req = urllib.request.Request(url, method="GET")
    req.add_header("Accept", "application/vnd.github+json")
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("User-Agent", "gameKelime-uploader")
    req.add_header("X-GitHub-Api-Version", "2022-11-28")
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return r.status, r.read()
    except urllib.error.HTTPError as e:
        return e.code, e.read()

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--owner", default="Mstf1086")
    ap.add_argument("--repo", default="gameKelime")
    ap.add_argument("--run", required=True)
    ap.add_argument("--out", default="/tmp/actions-log.zip")
    a = ap.parse_args()
    tok = os.environ.get("GITHUB_TOKEN", "")
    if not tok:
        print("GITHUB_TOKEN yok"); sys.exit(2)
    url = f"https://api.github.com/repos/{a.owner}/{a.repo}/actions/runs/{a.run}/logs"
    st, body = get(url, tok)
    print("status:", st, "bytes:", len(body))
    if st != 200:
        print(body[:500].decode(errors="replace")); sys.exit(1)
    open(a.out, "wb").write(body)
    print("yazildi:", a.out)
    z = zipfile.ZipFile(io.BytesIO(body))
    print("log dosyalari:", z.namelist()[:20])
