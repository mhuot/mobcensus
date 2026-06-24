# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Verified support for **Minecraft 26.1.x** (26.1 / 26.1.1 / 26.1.2). Their data
  pack format is `101`, already inside the pack's declared `101`–`107` range, so
  no `pack.mcmeta` change was needed. The functional CI matrix now boots 26.1.2
  alongside 26.2 to prove it loads and behaves identically.

## [2.1.0] - 2026-06-24

### Added

- `/function mobcensus:loaders` — reports only **unattended** cap clusters (no
  player within 128 blocks), classifying each as `portal_loader` or
  `stasis_chamber` (an ender pearl ticking nearby). Cluster records now carry
  `loader_suspect` (byte) and `origin_type` (string); unattended clusters are
  also collected into storage `mobcensus:find loaders`. New functional tests
  cover the classification.

### Fixed

- `loaded` listed every hostile once **per dimension** because a bare `@e`
  selector is not dimension-scoped (it already spans all dimensions). Reverted
  to a single pass; the same fix applies to `loaders`. (Corrects a `loaded`
  triple-listing introduced in 2.0.0.)

## [2.0.0] - 2026-06-24

### Added

- `/function mobcensus:cap` — per-dimension monster-cap **fill and percent**
  (e.g. "Overworld monster cap: 47 / 70 (67%)"), mirrored to storage
  `mobcensus:find cap.<dim>`.
- `#mobcensus:cap_mobs` — the **cap-accurate** set (monster-category natural
  spawners; no bosses, shulkers, or warden). The cap lane uses only this.
- **Click-to-teleport** output for `here`, `loaded`, and `hotspots`
  (dimension-aware, 26.2 `click_event` format).
- `/function mobcensus:config` and storage config `mobcensus:config` for
  `radius` (128), `cluster` (16), and `region` (256) — changeable without
  editing functions, and persistent across reloads.
- Functional test suite (`tests/functional_test.py`) plus a CI workflow that
  boots a real 26.2 server and asserts behaviour **and that every function
  loads**. Pack icon and example-output image.

### Changed

- `hotspots` is now **cap-accurate** (non-persistent `cap_mobs` only),
  clickable, and reported worst-first.
- `#mobcensus:hostiles` is now defined as `#mobcensus:cap_mobs` + shulker +
  warden — the same broad set as before, now DRY.
- `loaded` genuinely scans all three dimensions (previously only the runner's).

### Fixed

- `hotspots` failed to load entirely in 1.1.0 because of an invalid
  `distance=..1.0E8` selector (scientific notation is not accepted). Replaced
  with a plain bound; the new functional CI guards this regression class.

## [1.1.0] - 2026-06-23

### Added

- `/function mobcensus:hotspots` — groups the cap-eating hostiles (non-persistent
  monster-category mobs within 128 blocks of a player, scoped to the current
  dimension) into 16-block clusters and reports each hotspot's coordinates and
  size, plus the single biggest one. Cluster data is also written to storage
  `mobcensus:find clusters` / `mobcensus:find biggest` for RCON use.

## [1.0.0] - 2026-06-23

### Added

- `#mobcensus:hostiles` entity-type tag covering the monster-category mobs
  (entries marked `required: false` so a missing id never breaks loading).
- `/function mobcensus:here` — hostiles within 128 blocks of the runner,
  coordinates + total.
- `/function mobcensus:loaded` — every loaded hostile across all dimensions,
  coordinates + dimension + total.
- `/function mobcensus:counts` — per-type counts written to storage
  `mobcensus:find counts` (RCON-friendly via `data get`).
- `/function mobcensus:help` and an on-load greeting.
- README with usage, RCON notes, and status badges; MIT license.
- CI/CD: validate + lint (black, pylint) + build on every push/PR, and a
  tag-triggered workflow that publishes a versioned datapack zip as a release.

[Unreleased]: https://github.com/mhuot/mobcensus/compare/v2.1.0...HEAD
[2.1.0]: https://github.com/mhuot/mobcensus/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/mhuot/mobcensus/compare/v1.1.0...v2.0.0
[1.1.0]: https://github.com/mhuot/mobcensus/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/mhuot/mobcensus/releases/tag/v1.0.0
