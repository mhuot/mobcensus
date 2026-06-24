# Modrinth listing prep

Everything needed to publish mobcensus on Modrinth. Project creation + the
"submit for review" step need a logged-in Modrinth account, so they're manual;
this file is the copy-paste source.

## Project fields

| Field | Value |
| --- | --- |
| Project type | **Data Pack** |
| Name | `mobcensus` |
| Slug | `mobcensus` |
| Summary | Estimate the hostile mob-cap fill per dimension and teleport to the hotspots eating it. |
| Icon | `icon.png` (512×512) |
| License | MIT |
| Source | https://github.com/mhuot/mobcensus |
| Issues | https://github.com/mhuot/mobcensus/issues |
| Categories | `utility`, `management` |
| Body | paste `README.md` |

## Environment / compatibility

- Client side: **unsupported** · Server side: **required** (server-side datapack)
- Game versions: **26.2**
- Loaders: **Datapack**, and also tag **Fabric** + **Paper** so it surfaces for
  those platforms (a Datapack-only tag can read as "incompatible with vanilla";
  see modrinth/code#3538).

## Version upload

- Version number: match the git tag (e.g. `2.0.0`), channel **release**
- File: the `mobcensus-vX.Y.Z.zip` from the matching GitHub release
- Changelog: paste the matching section from `CHANGELOG.md`

## Automating future uploads

Once the project exists, add a `MODRINTH_TOKEN` repo secret and a
`Kir-Antipov/mc-publish` step to `release.yml` so each `vX.Y.Z` tag uploads the
zip to Modrinth automatically.
