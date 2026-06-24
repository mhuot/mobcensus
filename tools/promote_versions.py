"""Promote newly passing release versions into the supported test matrix.

Reads marker files (one per version that passed version-watch). For any that
are RELEASES (no -snapshot/-pre/-rc suffix) and not already listed, adds them to
``supported-versions.json`` and regenerates the verified-versions block in
README.md. Prints ``changed=true`` or ``changed=false`` on stdout so the
workflow can decide whether to commit.

Usage:
    python tools/promote_versions.py [markers_dir]
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SUPPORTED = ROOT / "supported-versions.json"
README = ROOT / "README.md"
RELEASE_RE = re.compile(r"^\d+(?:\.\d+)*$")
MARKER = "verified-versions"


def version_key(version: str) -> tuple[int, ...]:
    """Sort key turning '26.1.2' into (26, 1, 2)."""
    return tuple(int(part) for part in version.split("."))


def passing_releases(markers_dir: Path) -> set[str]:
    """Collect release version ids from the marker files under markers_dir."""
    found: set[str] = set()
    if not markers_dir.is_dir():
        return found
    for path in markers_dir.rglob("*"):
        if path.is_file():
            vid = path.read_text(encoding="utf-8").strip() or path.name
            if RELEASE_RE.match(vid):
                found.add(vid)
    return found


def regen_block(text: str, content: str) -> str:
    """Replace the marked verified-versions block in text with content."""
    start, end = f"<!-- {MARKER}:start -->", f"<!-- {MARKER}:end -->"
    pattern = re.compile(re.escape(start) + r".*?" + re.escape(end), re.DOTALL)
    return pattern.sub(f"{start}\n{content}\n{end}", text)


def main() -> None:
    """Add any newly passing releases and regenerate the README block."""
    markers = Path(sys.argv[1] if len(sys.argv) > 1 else "passed")
    supported = set(json.loads(SUPPORTED.read_text(encoding="utf-8")))
    additions = {v for v in passing_releases(markers) if v not in supported}
    if not additions:
        print("changed=false")
        return
    merged = sorted(supported | additions, key=version_key)
    SUPPORTED.write_text(json.dumps(merged, indent=2) + "\n", encoding="utf-8")
    README.write_text(
        regen_block(README.read_text(encoding="utf-8"), ", ".join(merged)),
        encoding="utf-8",
    )
    print(f"added releases: {sorted(additions, key=version_key)}", file=sys.stderr)
    print("changed=true")


if __name__ == "__main__":
    main()
