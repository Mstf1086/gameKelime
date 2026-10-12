"""gameKelime -> GitHub REST API yukleme (stdlib only, git/gh yok).

Kullanim:
  uv run python tools/gh_upload.py --dry-run
  GITHUB_TOKEN=ghp_xxx uv run python tools/gh_upload.py

Token: github.com -> Settings -> Developer settings -> PAT classic (scope: repo).
"""
import argparse
import base64
import json
import os
import sys
import urllib.request
import urllib.error
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
API = "https://api.github.com"
INCLUDE = ["lib", "docs", ".github", "assets", "test", "tools/gh_upload.py", "tools/make_zip.py",
           "tools/seed_levels.py", "tools/gh_log.py", "tools/make_keystore.py",
           "tools/patch_signing.py", "tools/set_secrets.py",
           "pubspec.yaml", "README.md",
           "INSTALL.md", "RULES.md", ".gitignore", ".firebaserc",
           "firebase.json", "firestore.rules", "firestore.indexes.json"]
EXCLUDE_DIRS = {".git", ".venv", "build", ".dart_tool", ".idea", ".vscode",
                "dist", "__pycache__"}

def collect_files():
    files = []
    for name in INCLUDE:
        p = ROOT / name
        if not p.exists():
            print(f"atlandi (yok): {name}")
            continue
        if p.is_file():
            files.append(p)
        else:
            for f in sorted(p.rglob("*")):
                if not f.is_file():
                    continue
                if any(part in EXCLUDE_DIRS for part in f.relative_to(ROOT).parts):
                    continue
                files.append(f)
    return files


def api(method, url, token, data=None):
    body = json.dumps(data).encode() if data is not None else None
    req = urllib.request.Request(url, data=body, method=method)
    req.add_header("Accept", "application/vnd.github+json")
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("X-GitHub-Api-Version", "2022-11-28")
    req.add_header("User-Agent", "gameKelime-uploader")
    if data is not None:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return r.status, json.loads(r.read().decode() or "{}")
    except urllib.error.HTTPError as e:
        return e.code, {"error": e.read().decode()[:500]}


def run(owner, repo, branch, token, message, dry_run, skip_github=False):
    files = collect_files()
    if skip_github:
        files = [f for f in files if ".github" not in f.relative_to(ROOT).parts]
        print("(not: .github atlandi, workflow web UI'dan eklenecek)")
    print(f"dosya sayisi: {len(files)}")
    if dry_run:
        for f in files[:10]:
            print(" ", f.relative_to(ROOT))
        if len(files) > 10:
            print(f"  ... +{len(files) - 10} dosya")
        print("DRY-RUN: API'ye dokunulmadi.")
        return 0
    st, _ = api("GET", f"{API}/repos/{owner}/{repo}", token)
    if st == 404:
        print(f"repo yok, olusturuluyor: {owner}/{repo}")
        st2, r2 = api("POST", f"{API}/user/repos", token,
                      {"name": repo, "private": False, "auto_init": True})
        if st2 not in (200, 201):
            print(f"repo olusturma basarisiz ({st2}): {r2}")
            return 1
    elif st != 200:
        print(f"repo kontrol basarisiz ({st})")
        return 1
    st, ref = api("GET", f"{API}/repos/{owner}/{repo}/git/ref/heads/{branch}", token)
    base_tree, base_sha = None, None
    if st == 200:
        base_sha = ref["object"]["sha"]
        stc, commit = api("GET", f"{API}/repos/{owner}/{repo}/git/commits/{base_sha}", token)
        if stc == 200:
            base_tree = commit["tree"]["sha"]
    tree = []
    for i, f in enumerate(files, 1):
        b64 = base64.b64encode(f.read_bytes()).decode()
        stb, blob = api("POST", f"{API}/repos/{owner}/{repo}/git/blobs",
                        token, {"content": b64, "encoding": "base64"})
        if stb not in (200, 201):
            print(f"blob hata ({stb}) {f}: {blob}")
            return 1
        tree.append({"path": f.relative_to(ROOT).as_posix(),
                     "mode": "100644", "type": "blob", "sha": blob["sha"]})
        if i % 15 == 0:
            print(f"  blob {i}/{len(files)}")
    payload = {"tree": tree}
    if base_tree:
        payload["base_tree"] = base_tree
    stt, nt = api("POST", f"{API}/repos/{owner}/{repo}/git/trees", token, payload)
    if stt not in (200, 201):
        print(f"tree hata ({stt}): {nt}")
        return 1
    cp = {"message": message, "tree": nt["sha"]}
    if base_sha:
        cp["parents"] = [base_sha]
    stco, nc = api("POST", f"{API}/repos/{owner}/{repo}/git/commits", token, cp)
    if stco not in (200, 201):
        print(f"commit hata ({stco}): {nc}")
        return 1
    if base_sha:
        stu, _ = api("PATCH", f"{API}/repos/{owner}/{repo}/git/refs/heads/{branch}",
                     token, {"sha": nc["sha"]})
    else:
        stu, _ = api("POST", f"{API}/repos/{owner}/{repo}/git/refs",
                     token, {"ref": f"refs/heads/{branch}", "sha": nc["sha"]})
    if stu not in (200, 201):
        print(f"ref hata ({stu})")
        return 1
    print(f"OK: {owner}/{repo}@{branch} -> {nc['sha'][:7]} ({len(files)} dosya)")
    print(f"Actions: https://github.com/{owner}/{repo}/actions")
    return 0


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--owner", default="Mstf1086")
    ap.add_argument("--repo", default="gameKelime")
    ap.add_argument("--branch", default="main")
    ap.add_argument("--message", default="gameKelime v1.0.0")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--skip-github", action="store_true",
                    help=".github/workflows dosyasini atla (Workflows izni yoksa)")
    a = ap.parse_args()
    tok = os.environ.get("GITHUB_TOKEN", "")
    if not a.dry_run and not tok:
        print("HATA: GITHUB_TOKEN yok.")
        print("  GITHUB_TOKEN=ghp_xxx uv run python tools/gh_upload.py")
        sys.exit(2)
    sys.exit(run(a.owner, a.repo, a.branch, tok, a.message, a.dry_run, a.skip_github))

