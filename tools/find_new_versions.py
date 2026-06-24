"""Discover recently released Minecraft versions to test mobcensus against.

Reads Mojang's version manifest and emits GitHub Actions outputs:
  versions=<json array of version ids>
  count=<n>

Releases: any released within the lookback window, plus the current latest
release. Snapshots: only those whose target release line is the current release
or the next upcoming release (so we track the line we're on and the one coming
next, not every historical snapshot), plus the current latest snapshot tip.

Used by the scheduled version-watch workflow to drive a dynamic test matrix.
"""

from __future__ import annotations

import datetime as dt
import json
import os
import re
import sys
import urllib.request

MANIFEST = "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"
# Safety cap so an unexpectedly wide window can't spawn a giant matrix.
MAX_VERSIONS = 12


def fetch_manifest() -> dict:
    """Fetch and parse Mojang's version manifest."""
    req = urllib.request.Request(
        MANIFEST, headers={"User-Agent": "mobcensus-version-watch"}
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.load(resp)


def release_line(version_id: str) -> str | None:
    """Return the major.minor release line a version targets, e.g. '26.3'.

    Works for releases ('26.2'), patches ('26.2.1'), and dotted snapshots
    ('26.3-snapshot-1', '26.2-rc-2'). Returns None for unparseable ids.
    """
    match = re.match(r"^(\d+)\.(\d+)", version_id)
    return f"{match.group(1)}.{match.group(2)}" if match else None


def pick_versions(manifest: dict, lookback_hours: int, now: dt.datetime) -> list[str]:
    """Choose versions to test: recent releases + current/next-line snapshots."""
    cutoff = now - dt.timedelta(hours=lookback_hours)
    latest = manifest.get("latest", {})
    current_release = latest.get("release")
    latest_snapshot = latest.get("snapshot")

    # Snapshots are only tested if they target the current or next release line.
    allowed_lines = {
        line
        for line in (
            release_line(current_release or ""),
            release_line(latest_snapshot or ""),
        )
        if line
    }

    picked: list[str] = []
    if current_release:
        picked.append(current_release)

    for version in manifest.get("versions", []):
        vid = version["id"]
        vtype = version.get("type")
        if vtype not in ("release", "snapshot"):
            continue
        released = dt.datetime.fromisoformat(
            version["releaseTime"].replace("Z", "+00:00")
        )
        if released < cutoff:
            continue
        if vtype == "snapshot" and release_line(vid) not in allowed_lines:
            continue
        if vid not in picked:
            picked.append(vid)

    # Always include the current snapshot tip (it targets the next release line).
    if latest_snapshot and latest_snapshot not in picked:
        picked.append(latest_snapshot)

    return picked[:MAX_VERSIONS]


def main() -> None:
    """Emit the discovered version list as GitHub Actions outputs."""
    lookback = int(os.environ.get("LOOKBACK_HOURS", "30"))
    now = dt.datetime.now(dt.timezone.utc)
    picked = pick_versions(fetch_manifest(), lookback, now)
    print(f"picked {len(picked)} version(s): {picked}", file=sys.stderr)
    print(f"versions={json.dumps(picked)}")
    print(f"count={len(picked)}")


if __name__ == "__main__":
    main()
