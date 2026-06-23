"""Build a distributable ZIP of the mobcensus datapack.

The archive holds ``pack.mcmeta`` and the ``data/`` tree at its root (plus the
README and license) so it can be dropped straight into a world's
``datapacks/`` folder.
"""

from __future__ import annotations

import argparse
import zipfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
INCLUDED = ("pack.mcmeta", "data", "README.md", "LICENSE")


def iter_pack_files() -> list[Path]:
    """Return the files that belong in the datapack archive."""
    files: list[Path] = []
    for name in INCLUDED:
        target = REPO_ROOT / name
        if target.is_file():
            files.append(target)
        elif target.is_dir():
            files.extend(path for path in target.rglob("*") if path.is_file())
    return files


def build(output: Path) -> None:
    """Write the datapack ZIP to ``output``."""
    output.parent.mkdir(parents=True, exist_ok=True)
    files = iter_pack_files()
    with zipfile.ZipFile(output, "w", zipfile.ZIP_DEFLATED) as archive:
        for path in files:
            archive.write(path, path.relative_to(REPO_ROOT).as_posix())
    print(f"built {output} ({len(files)} files)")


def main() -> None:
    """Parse arguments and build the archive."""
    parser = argparse.ArgumentParser(description="Build the mobcensus datapack ZIP")
    parser.add_argument(
        "--output",
        type=Path,
        default=REPO_ROOT / "dist" / "mobcensus.zip",
        help="path of the ZIP file to create",
    )
    args = parser.parse_args()
    build(args.output)


if __name__ == "__main__":
    main()
