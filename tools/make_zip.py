"""gameKelime manuel GitHub yukleme zibi (.venv python ile calistir)."""
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "dist" / "gameKelime-v1.0.0.zip"
INCLUDE = ["lib", "docs", ".github", "tools", "pubspec.yaml", "README.md", "INSTALL.md", "RULES.md", ".gitignore", ".firebaserc", "firebase.json", "firestore.rules", "firestore.indexes.json"]
EXCLUDE_DIRS = {".git", ".venv", "build", ".dart_tool", ".idea", ".vscode", "dist", "__pycache__"}

def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)
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
    with zipfile.ZipFile(OUT, "w", zipfile.ZIP_DEFLATED) as z:
        for f in files:
            z.write(f, f.relative_to(ROOT))
    print(f"OK: {OUT} ({OUT.stat().st_size // 1024} KB, {len(files)} dosya)")

if __name__ == "__main__":
    main()
