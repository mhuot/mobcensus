# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/mhuot/mobcensus/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/mhuot/mobcensus/releases/tag/v1.0.0
