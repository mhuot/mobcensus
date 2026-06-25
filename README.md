<div align="center">

<img src="icon.png" width="120" alt="mobcensus icon" />

# mobcensus

### How full is your hostile mob cap right now — and where is the load sitting?

A pure-vanilla Minecraft **datapack** (MC 26.1+) that answers the one question
vanilla never answers cleanly: it estimates the **monster mob-cap fill per
dimension**, and pinpoints the **hotspots** of cap-eating mobs so you can click
to teleport straight to them.

[![CI](https://github.com/mhuot/mobcensus/actions/workflows/ci.yml/badge.svg)](https://github.com/mhuot/mobcensus/actions/workflows/ci.yml)
[![Functional](https://github.com/mhuot/mobcensus/actions/workflows/functional.yml/badge.svg)](https://github.com/mhuot/mobcensus/actions/workflows/functional.yml)
[![Release](https://img.shields.io/github/v/release/mhuot/mobcensus?sort=semver)](https://github.com/mhuot/mobcensus/releases)
[![License: MIT](https://img.shields.io/github/license/mhuot/mobcensus)](LICENSE)
[![Minecraft](https://img.shields.io/badge/Minecraft-26.1%2B-62B47A?logo=minecraft&logoColor=white)](https://www.minecraft.net)

<img src="docs/demo.png" width="620" alt="example output" />

*Example output — every `[tp ...]` is click-to-teleport. (A live gameplay gif is the one thing not auto-generated; drop one in at `docs/demo.gif`.)*

</div>

---

## One set: the MONSTER spawn category

`#mobcensus:cap_mobs` is exactly Minecraft's `MobCategory.MONSTER` — the category
the hostile mob cap counts. Every command works off it and differs only in how
it filters:

| Commands | Filter | Use |
| --- | --- | --- |
| `cap`, `hotspots`, `loaders` | **non-persistent**, **within spawn range of a player** | what's actually eating the monster cap |
| `here`, `loaded`, `counts` | none — every loaded tagged mob, persistent included | just find / count mobs |

Because the set is the whole MONSTER category, a loaded shulker farm (a classic
cap-clog) now shows up in the cap numbers — it didn't before.

## Commands

| Command | Filter | What it does | Best from |
| --- | --- | --- | --- |
| `/function mobcensus:cap` | cap | Monster-cap **fill / estimated cap and percent, per dimension** | In-game / RCON |
| `/function mobcensus:hotspots` | cap | Cap-eaters grouped into hotspots, **worst first**, click-to-teleport | In-game / RCON |
| `/function mobcensus:loaders` | cap | **Unattended** clusters only (no player within 128) — flags portal-loader vs ender-pearl stasis | In-game / RCON |
| `/function mobcensus:here` | find | Monster-category mobs within your radius, click-to-teleport | In-game |
| `/function mobcensus:loaded` | find | Every loaded mob, **all dimensions**, click-to-teleport | In-game |
| `/function mobcensus:counts` | find | Per-type counts into storage | RCON |
| `/function mobcensus:config` | — | Show the tunables | In-game |
| `/function mobcensus:help` | — | Command list | In-game |

## How the cap number is estimated (and where it's approximate)

Vanilla's monster cap is:

```
monster_cap = 70 × eligible_chunks ÷ 289
```

`289` is the 17×17 chunk area around each player, and the game counts the
**union of unique chunks** across all players (so the cap grows as players
spread out). **A pure datapack cannot read the eligible-chunk count.** So
mobcensus approximates:

```
estimated_cap = 70 × (number of separated player groups in the dimension)
```

Each isolated player group is treated as one full 289-chunk (cap-70) area. The
fill is the count of non-persistent `#mobcensus:cap_mobs` within the configured
radius of a player. The math lives in comments in `cap.mcfunction` /
`_cap_calc.mcfunction` so it's auditable.

**Honest gaps** (see [the report below](#known-approximations)):
- Exact for a single player group; an approximation when players spread out (it
  ignores *partial* chunk overlap between groups).
- Assumes simulation distance ≥ 8 (the spawn-range cap). Lower settings shrink
  the real per-player area.
- Counts the MONSTER spawn category (non-persistent, in range); it does not model per-mob sub-rules
  (slime chunks, phantom-from-sleep) or the despawn sphere precisely.

## Unattended loaders (`loaders`)

`hotspots` only ever sees cap-eaters *near a player*. `loaders` is the inverse:
it scans **every loaded `cap_mobs` cluster across all dimensions** and reports
only the ones with **no player within 128 blocks** — i.e. mobs being kept alive
by a chunk loader while nobody's around. Each cluster is tagged on the
`clusters[]`/`loaders[]` records with:

- `loader_suspect`: `1b` if unattended, else `0b`
- `origin_type`: `"stasis_chamber"` if an ender pearl is ticking within 128
  blocks, otherwise `"portal_loader"` (or `"player_present"` when attended)

> [!NOTE]
> This is a **heuristic**. The 128-block player/pearl checks are coarse: a
> stasis pearl up to 128 blocks away can tag a *neighbouring* cluster as stasis,
> and any unrelated ticking pearl reads as a chamber. Treat it as a strong hint
> for "go look here", not proof.

## Configuration (no function editing)

Tunables live in storage `mobcensus:config` with sane defaults:

| Key | Default | Meaning |
| --- | --- | --- |
| `radius` | `128` | Spawn range scanned around each player |
| `cluster` | `16` | Hotspot grouping radius |
| `region` | `256` | Distance under which players share one cap "group" |

Change them with plain commands (they survive reloads):

```mcfunction
/data modify storage mobcensus:config radius set value 96
/function mobcensus:config        # show current values
```

## RCON usage

`tellraw` output isn't returned over RCON — command feedback and `data get`
are. Everything is mirrored to storage:

```bash
rcon-cli "function mobcensus:cap"
rcon-cli "data get storage mobcensus:find cap"
# → {overworld:{fill:47,cap:70,percent:67,players:1,regions:1}, nether:{...}, end:{...}}

rcon-cli "function mobcensus:hotspots"
rcon-cli "data get storage mobcensus:find clusters"   # worst-first: [{count:18,pos:[...]}, {count:9,...}, ...]

rcon-cli "function mobcensus:loaders"
rcon-cli "data get storage mobcensus:find loaders"    # unattended only, with origin_type

rcon-cli "function mobcensus:counts"
rcon-cli "data get storage mobcensus:find counts"     # {zombie:4, creeper:2, total:6, ...}
```

## Performance

No per-tick work — nothing runs unless you call it. Costs:

| Function | Cost |
| --- | --- |
| `cap` | 3 dimension passes; each = one player scan + a player-group recursion + one mob scan |
| `hotspots` | one scan to build the set, then one scan per emitted cluster (not per mob) |
| `loaders` | one scan to tag all loaded cap mobs, then one scan per cluster (all dimensions, one pass) |
| `here` | one scan + one line per hostile in range |
| `loaded` | one line per loaded hostile across three dimensions |
| `counts` | a handful of `if entity` scans |

Clustering is greedy and bounded by cluster count, so it stays cheap even with
hundreds of mobs. With no players online, the cap is correctly `0`.

## Install

1. Copy the `mobcensus` folder into your world: `<world>/datapacks/mobcensus/`
2. `/reload` (or restart). Confirm with `/datapack list` → `file/mobcensus`.

Requirements: a supported Minecraft version (see below), datapack format
`101`–`107`. Works on any world or server — vanilla, Fabric, Paper.

## Supported versions

Boot-tested on every change (CI) and kept current automatically — the
[version-watch](.github/workflows/version-watch.yml) workflow adds a new release
here once it passes:

<!-- verified-versions:start -->
26.1.2, 26.2
<!-- verified-versions:end -->

## Development

```bash
python scripts/validate_pack.py                  # metadata + JSON
python scripts/build.py --output dist/mobcensus.zip
python tests/functional_test.py mc-mayhem        # behavioural tests vs a live server
```

CI runs **validate → lint (black, pylint) → build**, plus a **functional**
workflow that boots real 26.1.2 and 26.2 servers, asserts every function loads (no parse
regressions), and checks clustering, counts, tag lanes, and the cap math.
A daily **version-watch** workflow discovers newly released Minecraft versions
(releases + snapshots) from Mojang's manifest and runs the same suite against
each, opening a tracking issue when one needs attention (e.g. a data pack
format beyond `max_format`). Tagging `vX.Y.Z` builds and publishes a release zip.

## License

[MIT](LICENSE) © Mike Huot
