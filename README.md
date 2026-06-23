<div align="center">

# 🧟 mobcensus

### Find every hostile on your map — and see what's eating your mob cap.

A lightweight Minecraft **datapack** that locates hostile mobs and measures
hostile **mob-cap pressure** with a reusable entity tag and a handful of
drop-in functions.

[![CI](https://github.com/mhuot/mobcensus/actions/workflows/ci.yml/badge.svg)](https://github.com/mhuot/mobcensus/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/mhuot/mobcensus?sort=semver)](https://github.com/mhuot/mobcensus/releases)
[![License: MIT](https://img.shields.io/github/license/mhuot/mobcensus)](LICENSE)
[![Minecraft](https://img.shields.io/badge/Minecraft-26.2-62B47A?logo=minecraft&logoColor=white)](https://www.minecraft.net)
[![pack_format](https://img.shields.io/badge/pack__format-101–107-1f6feb)](pack.mcmeta)

</div>

---

## ✨ Features

- 🎯 **Pinpoint hostiles** — dump coordinates of every hostile, near you or world-wide
- 📊 **Mob-cap insight** — per-type counts to find what's clogging the monster cap
- 🏷️ **Reusable tag** — `#mobcensus:hostiles` works in your own selectors
- 🖥️ **RCON-friendly** — counts come back over the console, no client needed
- 🪶 **Zero dependencies** — pure vanilla datapack, drops into any world or server

## 🚀 Quick start

```bash
# 1. copy the pack into your world
cp -r mobcensus <world>/datapacks/

# 2. in-game or via console
/reload

# 3. confirm it loaded
/datapack list      # → file/mobcensus
```

> [!TIP]
> Prefer a packaged build? Grab `mobcensus-vX.Y.Z.zip` from the
> [latest release](https://github.com/mhuot/mobcensus/releases/latest) and drop
> the zip straight into `datapacks/`.

## 🎮 Commands

| Command | What it does | Best from |
| --- | --- | --- |
| `/function mobcensus:here` | Hostiles within 128 blocks of you — coords + total | In-game (op) |
| `/function mobcensus:loaded` | Every loaded hostile, all dimensions — coords + dimension + total | In-game (op) |
| `/function mobcensus:counts` | Per-type counts → storage `mobcensus:find counts` | Console / RCON |
| `/function mobcensus:help` | Usage reminder | In-game |

### 🏷️ The `#mobcensus:hostiles` tag

It's a normal entity-type tag, so use it anywhere a selector is accepted:

```mcfunction
execute if entity @e[type=#mobcensus:hostiles]      # quick total of loaded hostiles
```

## 🖥️ RCON usage

Over RCON, `tellraw` output isn't returned — only command feedback and
`data get` are:

```bash
rcon-cli "execute if entity @e[type=#mobcensus:hostiles]"   # → Test passed. Count: N

rcon-cli "function mobcensus:counts"
rcon-cli "data get storage mobcensus:find counts"
# → {zombie: 4, creeper: 2, total: 6, ...}
```

## 🛠️ Development

```bash
python scripts/validate_pack.py        # validate metadata + all JSON
python scripts/build.py --output dist/mobcensus.zip   # package the datapack
```

CI runs on every push/PR (**validate → lint → build**); pushing a `vX.Y.Z` tag
builds a versioned zip and publishes a GitHub Release automatically.

```bash
git tag v1.2.3 && git push origin v1.2.3   # cut a release
```

## 📝 Notes

- **Counts need loaded chunks.** With no players online nothing spawns, so every
  count reads `0`. Run the functions while players are active near the area.
- The tag includes some mobs that don't fill the *ambient* monster cap (bosses,
  raid mobs, shulkers, warden) so it's useful as a general hostile-finder; for
  cap analysis, focus on naturally-spawning mobs near players.
- Tag entries are `required: false`, so an id missing in a given version is
  skipped instead of breaking the pack.

## 📦 Requirements

- Minecraft **26.2** (datapack format `101`–`107`)
- Any world or server — vanilla, Fabric, Paper, …

## 📄 License

[MIT](LICENSE) © Mike Huot
