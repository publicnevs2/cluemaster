#!/usr/bin/env python3
"""
PROJECT SNAPSHOT for LLM handover
- Creates:
  - TREE.md with a concise directory tree
  - PROJECT_SNAPSHOT_partN.md with concatenated file contents (chunked)
"""
import os, sys, io, time, hashlib, subprocess
from pathlib import Path

# --- Einstellungen ---
ROOT = Path(__file__).resolve().parent.parent  # Repo-Root = Ordner über /tools
OUT_DIR = ROOT / "llm_export"
TREE_FILE = OUT_DIR / "TREE.md"

# Ordner ausschließen
EXCLUDE_DIRS = {
    ".git", ".idea", ".vscode", ".dart_tool", ".gradle", "build",
    "ios/Pods", "android/.gradle", "android/app/build", "node_modules"
}

# Dateiendungen, die typischerweise für Flutter/Android relevant sind
INCLUDE_EXTS = {
    ".dart", ".yaml", ".yml", ".md", ".txt",
    ".json", ".xml", ".properties",
    ".gradle", ".kts", ".pro", ".sh", ".bat",
    ".kt", ".java"
}

# Maximale Größen
MAX_BYTES_PER_FILE = 120_000      # 120 KB pro Datei
MAX_BYTES_PER_SNAPSHOT = 1_200_000  # 1.2 MB pro Snapshot (Chunking)

# Zusätzliche Ignore-Dateien (optional): .gptignore funktioniert wie .gitignore light
EXTRA_IGNORES = {line.strip() for line in (ROOT / ".gptignore").read_text(encoding="utf-8", errors="ignore").splitlines()
                 if line.strip() and not line.strip().startswith("#")} if (ROOT / ".gptignore").exists() else set()

def is_binary_like(p: Path) -> bool:
    # einfache Heuristik: bekannte Binär-Endungen
    BIN_EXTS = {".png", ".jpg", ".jpeg", ".gif", ".webp", ".ico",
                ".aab", ".apk", ".so", ".keystore", ".bin", ".pdf",
                ".ttf", ".otf", ".mp3", ".wav", ".mp4"}
    return p.suffix.lower() in BIN_EXTS

def should_skip_dir(p: Path) -> bool:
    # Treffer, wenn ein Teilpfad in EXCLUDE_DIRS ist (robust gegen verschachtelte Pfade)
    parts = set()
    acc = []
    for part in p.relative_to(ROOT).parts:
        acc.append(part)
        parts.add("/".join(acc))
        parts.add(part)
    return any(d in parts for d in EXCLUDE_DIRS)

def matches_extra_ignore(p: Path) -> bool:
    # sehr einfache Glob-Prüfung (nur Suffix- oder Teilstring-Matches)
    rel = str(p.relative_to(ROOT)).replace("\\", "/")
    for pat in EXTRA_IGNORES:
        if pat.endswith("/"):
            if rel.startswith(pat):
                return True
        elif pat.startswith("*."):
            if rel.lower().endswith(pat[1:].lower()):
                return True
        else:
            if pat in rel:
                return True
    return False

def current_git_rev():
    try:
        rev = subprocess.check_output(["git", "rev-parse", "--short", "HEAD"], cwd=ROOT, timeout=3)
        return rev.decode().strip()
    except Exception:
        return None

def gather_files():
    files = []
    for dirpath, dirnames, filenames in os.walk(ROOT):
        d = Path(dirpath)
        # Filter Ordner in-place (verhindert Descend)
        pruned = []
        for name in list(dirnames):
            sub = d / name
            rel = sub.relative_to(ROOT)
            if should_skip_dir(sub):
                continue
            pruned.append(name)
        dirnames[:] = pruned

        for fn in filenames:
            p = d / fn
            # Out dir & Skript selbst nicht exportieren
            if OUT_DIR in p.parents or p == Path(__file__):
                continue
            if matches_extra_ignore(p):
                continue
            if is_binary_like(p):
                continue
            if p.suffix.lower() not in INCLUDE_EXTS:
                continue
            files.append(p)
    files.sort()
    return files

def safe_read_text(p: Path, limit=MAX_BYTES_PER_FILE):
    try:
        data = p.read_bytes()
        if len(data) > limit:
            data = data[:limit]
            truncated = True
        else:
            truncated = False
        text = data.decode("utf-8", errors="replace")
        return text, truncated
    except Exception as e:
        return f"<<READ ERROR: {e}>>", True

def write_tree_md(files):
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    # baue ein kompaktes „tree“ mit Größen
    from collections import defaultdict
    by_dir = defaultdict(list)
    for f in files:
        by_dir[str(f.parent.relative_to(ROOT)) or "."] .append(f)

    lines = []
    lines.append(f"# Project Tree – {time.strftime('%Y-%m-%d %H:%M:%S')}")
    gitrev = current_git_rev()
    if gitrev:
        lines.append(f"- Git rev: `{gitrev}`")
    lines.append("")
    def rel(p: Path) -> str:
        return str(p.relative_to(ROOT)).replace("\\", "/")

    for folder in sorted(by_dir.keys()):
        lines.append(f"## {folder}")
        for f in by_dir[folder]:
            try:
                size = f.stat().st_size
            except Exception:
                size = 0
            lines.append(f"- {rel(f)} ({size} B)")
        lines.append("")
    TREE_FILE.write_text("\n".join(lines), encoding="utf-8")

def write_snapshots(files):
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    part_idx = 1
    buf = io.StringIO()
    total = 0

    header = []
    header.append(f"# Project Snapshot – {time.strftime('%Y-%m-%d %H:%M:%S')}")
    gitrev = current_git_rev()
    if gitrev:
        header.append(f"- Git rev: `{gitrev}`")
    header.append("- Export format: one fenced section per file (`path` + content).")
    header.append("")
    buf.write("\n".join(header))

    def flush_part():
        nonlocal part_idx, buf, total
        out_path = OUT_DIR / f"PROJECT_SNAPSHOT_part{part_idx}.md"
        out_path.write_text(buf.getvalue(), encoding="utf-8")
        part_idx += 1
        buf = io.StringIO()
        total = 0
        buf.write("\n".join(header))

    for p in files:
        rel = str(p.relative_to(ROOT)).replace("\\", "/")
        content, truncated = safe_read_text(p)
        section = []
        section.append(f"\n---\n## {rel}\n")
        if truncated:
            section.append(f"_Note: truncated to {MAX_BYTES_PER_FILE} bytes._\n")
        section.append("```")
        section.append(content.rstrip("\n"))
        section.append("```\n")
        section_text = "\n".join(section)
        size = len(section_text.encode("utf-8"))

        if total + size > MAX_BYTES_PER_SNAPSHOT and total > 0:
            flush_part()
        buf.write(section_text)
        total += size

    # final flush
    out_path = OUT_DIR / f"PROJECT_SNAPSHOT_part{part_idx}.md"
    out_path.write_text(buf.getvalue(), encoding="utf-8")

def main():
    files = gather_files()
    write_tree_md(files)
    write_snapshots(files)
    print(f"Export written to: {OUT_DIR}")

if __name__ == "__main__":
    main()
