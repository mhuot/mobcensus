# Macro: radius. Lists hostiles within radius of the runner, click-to-teleport.
tag @s add mobcensus.viewer
$execute store result score #n mobcensus if entity @e[type=#mobcensus:hostiles, distance=..$(radius)]
$tellraw @a[tag=mobcensus.viewer] ["", {"text": "-- hostiles within $(radius) blocks: ", "color": "gold"}, {"score": {"name": "#n", "objective": "mobcensus"}, "color": "yellow"}, {"text": " --", "color": "gold"}]
$execute as @e[type=#mobcensus:hostiles, distance=..$(radius), sort=nearest] run function mobcensus:_find_emit
tag @s remove mobcensus.viewer
