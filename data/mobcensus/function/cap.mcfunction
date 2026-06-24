# Per-dimension hostile mob-cap fill: how full is the monster cap right now.
#
# Vanilla monster cap = 70 * eligible_chunks / 289, where 289 is the 17x17
# chunk area around each player and the game counts the UNION of unique chunks
# across players. A pure datapack cannot read the eligible-chunk count, so we
# approximate: each separated player group ("region") contributes one full
# 289-chunk (cap-70) area, giving cap = 70 * regions. This is exact for a
# single group and approximate when players spread out (it ignores partial
# overlap and simulation distance below 8). See README for the documented gap.
#
# Fill = non-persistent #mobcensus:cap_mobs within the configured radius of a
# player. Output is mirrored to storage mobcensus:find cap.<dim> for RCON.
#
# Cost: per call, three dimension passes (player scan + region count + one mob
# scan each). No per-tick work.
data modify storage mobcensus:find cap set value {}
tellraw @a ["", {"text": "-- monster mob cap (fill / est. cap) --", "color": "gold"}]
function mobcensus:_cap_dim {dim: "minecraft:overworld", name: "Overworld", key: "overworld"}
function mobcensus:_cap_dim {dim: "minecraft:the_nether", name: "Nether", key: "nether"}
function mobcensus:_cap_dim {dim: "minecraft:the_end", name: "The End", key: "end"}
execute unless entity @a run tellraw @a ["", {"text": "  no players online - cap is 0 everywhere", "color": "gray"}]
