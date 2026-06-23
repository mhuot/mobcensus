"""Validate the mobcensus datapack structure and JSON files.

Exits non-zero if ``pack.mcmeta`` is missing or malformed, or if any JSON file
under ``data/`` fails to parse, so it can act as a CI gate.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import NoReturn

REPO_ROOT = Path(__file__).resolve().parent.parent
PACK_META = REPO_ROOT / "pack.mcmeta"
DATA_DIR = REPO_ROOT / "data"


def fail(message: str) -> NoReturn:
    """Print an error in GitHub Actions format and exit non-zero."""
    print(f"::error::{message}")
    sys.exit(1)


def validate_pack_meta() -> None:
    """Ensure pack.mcmeta exists, is valid JSON, and declares a pack format."""
    if not PACK_META.is_file():
        fail("pack.mcmeta is missing")
    try:
        meta = json.loads(PACK_META.read_text(encoding="utf-8"))
    except json.JSONDecodeError as err:
        fail(f"pack.mcmeta is not valid JSON: {err}")

    pack = meta.get("pack", {})
    has_single = "pack_format" in pack
    has_range = "min_format" in pack and "max_format" in pack
    if not (has_single or has_range):
        fail("pack.mcmeta is missing pack_format or min_format/max_format")
    print("pack.mcmeta OK")


def validate_json_files() -> None:
    """Parse every JSON file under data/ to catch syntax errors early."""
    json_files = sorted(DATA_DIR.rglob("*.json"))
    if not json_files:
        fail("no JSON files found under data/")
    for path in json_files:
        try:
            json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as err:
            fail(f"{path.relative_to(REPO_ROOT)}: invalid JSON: {err}")
    print(f"validated {len(json_files)} JSON file(s)")


def main() -> None:
    """Run all validation checks."""
    validate_pack_meta()
    validate_json_files()
    print("mobcensus datapack validation passed")


if __name__ == "__main__":
    main()
