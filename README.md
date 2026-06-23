# mobcensus

A lightweight Minecraft datapack for **locating hostile mobs** and gauging
**hostile mob-cap pressure** on a world or server. It adds a reusable
`#mobcensus:hostiles` entity tag plus a few functions that report mob
coordinates and per-type counts — handy for tracking down the dark cave, the
misbehaving farm, or the trapped herd that's eating your monster cap.

## Requirements

- Minecraft **26.2** (datapack format `101`–`107`)
- Works on any world or server (vanilla, Fabric, Paper, …) — it's a pure datapack

## Install

1. Drop the `mobcensus` folder into your world's `datapacks/` directory:
   `<world>/datapacks/mobcensus/`
2. In-game (or via console) run `/reload`
3. Confirm it loaded: `/datapack list` should show `file/mobcensus`

## Commands

| Command | Description | Best run from |
| --- | --- | --- |
| `/function mobcensus:here` | Hostiles within 128 blocks of you — coordinates + total | In-game (op) |
| `/function mobcensus:loaded` | Every loaded hostile, all dimensions — coordinates + dimension + total | In-game (op) |
| `/function mobcensus:counts` | Per-type counts written to storage `mobcensus:find counts` | Console / RCON |
| `/function mobcensus:help` | Usage reminder | In-game |

### The `#mobcensus:hostiles` tag

The pack defines an entity-type tag covering the monster-category mobs. It's a
normal tag, so you can use it directly in your own selectors:

```mcfunction
# quick total of all loaded hostiles
execute if entity @e[type=#mobcensus:hostiles]
```

## RCON usage

Over RCON, `tellraw` output is **not** returned — only command feedback and
`data get` are. So:

```bash
# quick total
rcon-cli "execute if entity @e[type=#mobcensus:hostiles]"     # -> Test passed. Count: N

# per-type breakdown (two steps)
rcon-cli "function mobcensus:counts"
rcon-cli "data get storage mobcensus:find counts"             # -> {zombie: 4, creeper: 2, total: 6, ...}

# a single mob's position
rcon-cli "data get entity @e[type=#mobcensus:hostiles,limit=1] Pos"
```

## Notes

- **Counts only mean something while chunks are loaded.** With no players
  online, nothing spawns or ticks, so every count reads `0`. Run the functions
  while players are active (ideally near the area you're investigating).
- The tag includes a few mobs that don't fill the natural *ambient* monster cap
  (bosses, raid mobs, shulkers, the warden). They're included so the pack is
  useful as a general "find hostiles" tool; for cap analysis, focus on the
  naturally-spawning mobs near players.
- Tag entries are marked `required: false`, so a mob id that doesn't exist in a
  given version is skipped rather than breaking the pack.

## License

MIT — see [LICENSE](LICENSE).
