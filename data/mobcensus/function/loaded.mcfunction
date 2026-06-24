# Every loaded hostile across ALL dimensions (general finder lane). Each result
# is click-to-teleport (dimension-aware). Cost: one line per loaded hostile.
tag @s add mobcensus.viewer
tellraw @a[tag=mobcensus.viewer] ["", {"text": "-- loaded hostiles (all dimensions) - click to teleport --", "color": "gold"}]
execute in minecraft:overworld run function mobcensus:_loaded_dim
execute in minecraft:the_nether run function mobcensus:_loaded_dim
execute in minecraft:the_end run function mobcensus:_loaded_dim
tag @s remove mobcensus.viewer
