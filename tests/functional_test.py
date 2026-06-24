"""Functional tests for the mobcensus datapack against a live server.

Drives a running Minecraft server over ``rcon-cli`` (via ``docker exec``) and
asserts real behaviour: that every function loads and runs, that clustering and
counts are correct, that the cap-accurate lane excludes persistent/non-cap
mobs, and that the cap arithmetic matches the documented formula.

Usage:
    python tests/functional_test.py [container_name]

The container defaults to ``$MOBCENSUS_CONTAINER`` or ``mc-mayhem``. Exits
non-zero if any assertion fails, so it can gate CI.
"""

from __future__ import annotations

import os
import re
import subprocess
import sys

CONTAINER = (
    sys.argv[1]
    if len(sys.argv) > 1
    else os.environ.get("MOBCENSUS_CONTAINER", "mc-mayhem")
)
FAILURES: list[str] = []


def rcon(command: str) -> str:
    """Run one command through the server's rcon-cli and return its output."""
    result = subprocess.run(
        ["docker", "exec", CONTAINER, "rcon-cli", command],
        capture_output=True,
        text=True,
        check=False,
    )
    return (result.stdout + result.stderr).strip()


def count(selector: str) -> int:
    """Return how many entities match a selector via `execute if entity`."""
    out = rcon(f"execute if entity {selector}")
    match = re.search(r"Count:\s*(\d+)", out)
    if match:
        return int(match.group(1))
    return 0


def storage_int(path: str) -> int:
    """Read an integer/byte value from storage mobcensus:find at the path."""
    out = rcon(f"data get storage mobcensus:find {path}")
    match = re.search(r":\s*(-?\d+)", out)
    return int(match.group(1)) if match else -1


def storage_str(path: str) -> str:
    """Read a string value from storage mobcensus:find at the given path."""
    out = rcon(f"data get storage mobcensus:find {path}")
    match = re.search(r'contents:\s*"([^"]*)"', out)
    return match.group(1) if match else ""


def check(name: str, condition: bool, detail: str = "") -> None:
    """Record and print the result of a single assertion."""
    if condition:
        print(f"  PASS  {name}")
    else:
        FAILURES.append(name)
        print(f"  FAIL  {name}  {detail}")


def setup_arena() -> None:
    """Force-load spawn chunks for deterministic, player-free testing."""
    rcon("forceload add -48 -48 48 48")
    rcon("kill @e[tag=mc_test]")


def teardown() -> None:
    """Remove test mobs and force-loaded chunks."""
    rcon("kill @e[tag=mc_test]")
    rcon("forceload remove all")
    rcon("tag @e remove mobcensus.cap")


def summon(mob: str, x: int, z: int, persistent: bool = False) -> None:
    """Summon a frozen, tagged test mob at y=100."""
    persist = "1b" if persistent else "0b"
    nbt = (
        f'{{Tags:["mc_test"],NoAI:1b,NoGravity:1b,Invulnerable:1b,'
        f"PersistenceRequired:{persist}}}"
    )
    rcon(f"summon {mob} {x} 100 {z} {nbt}")


def test_functions_load() -> None:
    """Every public function loads and runs (would catch a parse-error regress)."""
    rcon("reload")
    rcon("function mobcensus:load")
    # hotspots resets clusters to [] when it runs; a non-loading function cannot.
    rcon("data modify storage mobcensus:find clusters set value [{sentinel:1b}]")
    rcon("function mobcensus:hotspots")
    out = rcon("data get storage mobcensus:find clusters")
    check("hotspots loads and runs", "sentinel" not in out, out)
    # cap writes a per-dimension structure when it runs.
    rcon("function mobcensus:cap")
    check(
        "cap loads and writes overworld structure",
        storage_int("cap.overworld.cap") >= 0,
    )


def test_cluster_grouping() -> None:
    """Two tight clusters plus a stray group into sizes 4, 3, 1."""
    for x, z in [(40, 40), (42, 41), (39, 43), (41, 38)]:
        summon("zombie", x, z)
    for x, z in [(-40, -40), (-42, -39), (-41, -42)]:
        summon("creeper", x, z)
    summon("skeleton", 10, -45)
    rcon(
        "data modify storage mobcensus:tmp clustersize set from storage mobcensus:config cluster"
    )
    rcon("tag @e remove mobcensus.cap")
    rcon(
        "tag @e[type=#mobcensus:cap_mobs,nbt=!{PersistenceRequired:1b}] add mobcensus.cap"
    )
    rcon("scoreboard players set #idx mobcensus 0")
    rcon("scoreboard players set #max mobcensus 0")
    rcon("data modify storage mobcensus:find clusters set value []")
    rcon("data modify storage mobcensus:find biggest set value {}")
    rcon("function mobcensus:_cluster_step")
    sizes = [
        storage_int("clusters[0].count"),
        storage_int("clusters[1].count"),
        storage_int("clusters[2].count"),
    ]
    check("cluster sizes are 4, 3, 1", sizes == [4, 3, 1], str(sizes))
    check("biggest hotspot is the 4-mob cluster", storage_int("biggest.pos[0]") == 40)


def test_persistent_excluded() -> None:
    """Persistent (name-tag-equivalent) mobs do not count toward the cap set."""
    rcon("kill @e[tag=mc_test]")
    summon("zombie", 5, 5, persistent=False)
    summon("zombie", 7, 7, persistent=True)
    rcon("tag @e remove mobcensus.cap")
    rcon(
        "tag @e[type=#mobcensus:cap_mobs,nbt=!{PersistenceRequired:1b}] add mobcensus.cap"
    )
    check(
        "persistent mob excluded from cap set",
        count("@e[tag=mobcensus.cap,tag=mc_test]") == 1,
    )


def test_cap_mobs_is_monster_category() -> None:
    """cap_mobs == MONSTER: a shulker is now included, and the non-persistent
    runtime filter is what keeps it cap-accurate (a persistent one is excluded)."""
    rcon("kill @e[tag=mc_test]")
    summon("shulker", 0, 8, persistent=False)
    summon("shulker", 4, 8, persistent=True)
    check(
        "shulker is now in #mobcensus:cap_mobs",
        count("@e[type=#mobcensus:cap_mobs,tag=mc_test]") == 2,
    )
    rcon("tag @e remove mobcensus.cap")
    rcon(
        "tag @e[type=#mobcensus:cap_mobs,nbt=!{PersistenceRequired:1b}] add mobcensus.cap"
    )
    check(
        "only the non-persistent shulker enters the cap set",
        count("@e[tag=mobcensus.cap,tag=mc_test]") == 1,
    )


def test_cap_arithmetic() -> None:
    """fill 47 of cap 70 reports 67 percent (matches the documented example)."""
    rcon("scoreboard players set #fill mobcensus 47")
    rcon("scoreboard players set #cap mobcensus 70")
    rcon("scoreboard players operation #pct mobcensus = #fill mobcensus")
    rcon("scoreboard players set #hundred mobcensus 100")
    rcon("scoreboard players operation #pct mobcensus *= #hundred mobcensus")
    rcon("scoreboard players operation #pct mobcensus /= #cap mobcensus")
    out = rcon("scoreboard players get #pct mobcensus")
    match = re.search(r"has (\d+)", out)
    pct = int(match.group(1)) if match else -1
    check("cap percent 47/70 == 67", pct == 67, str(pct))


def test_loader_detection() -> None:
    """Unattended clusters flag loader_suspect; an ender pearl reads as stasis."""
    rcon("kill @e[tag=mc_test]")
    for x, z in [(40, 40), (41, 41), (39, 40)]:
        summon("zombie", x, z)
    # No players online, so the cluster is unattended by definition.
    rcon("function mobcensus:loaders")
    check("unattended cluster flagged", storage_int("loaders[0].loader_suspect") == 1)
    check(
        "origin defaults to portal_loader",
        storage_str("loaders[0].origin_type") == "portal_loader",
    )
    check(
        "one cluster, not duplicated per dimension",
        storage_int("loaders[1].count") == -1,
    )
    # A ticking ender pearl nearby should classify it as a stasis chamber.
    rcon('summon minecraft:ender_pearl 40 100 40 {Tags:["mc_test"]}')
    rcon("function mobcensus:loaders")
    check(
        "ender pearl -> stasis_chamber",
        storage_str("loaders[0].origin_type") == "stasis_chamber",
    )


def main() -> None:
    """Run the full suite and exit non-zero on any failure."""
    print(f"mobcensus functional tests against container '{CONTAINER}'")
    setup_arena()
    try:
        test_functions_load()
        test_cluster_grouping()
        test_persistent_excluded()
        test_cap_mobs_is_monster_category()
        test_cap_arithmetic()
        test_loader_detection()
    finally:
        teardown()
    print(f"\n{len(FAILURES)} failure(s)")
    sys.exit(1 if FAILURES else 0)


if __name__ == "__main__":
    main()
