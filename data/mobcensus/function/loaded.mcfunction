# Every loaded hostile across ALL dimensions (general finder lane). A bare @e
# selector is not dimension-scoped, so a single pass covers every dimension.
# Each result is dimension-aware click-to-teleport. Cost: one line per hostile.
tag @s add mobcensus.viewer
execute store result score #n mobcensus if entity @e[type=#mobcensus:hostiles]
tellraw @a[tag=mobcensus.viewer] ["", {"text": "-- loaded hostiles (all dimensions): ", "color": "gold"}, {"score": {"name": "#n", "objective": "mobcensus"}, "color": "yellow"}, {"text": " - click to teleport --", "color": "gold"}]
execute as @e[type=#mobcensus:hostiles] run function mobcensus:_find_emit
tag @s remove mobcensus.viewer
