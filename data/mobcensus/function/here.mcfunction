# Hostiles within 128 blocks of the runner (in-game use). Relative distance is
# measured from the command's execution position, i.e. the player who runs it.
tag @s add mobcensus.viewer
execute store result storage mobcensus:find n int 1 if entity @e[type=#mobcensus:hostiles, distance=..128]
tellraw @a[tag=mobcensus.viewer] ["", {"text": "-- hostiles within 128 blocks: ", "color": "gold"}, {"storage": "mobcensus:find", "nbt": "n", "color": "yellow"}, {"text": " --", "color": "gold"}]
execute as @e[type=#mobcensus:hostiles, distance=..128, sort=nearest] run tellraw @a[tag=mobcensus.viewer] ["", {"selector": "@s", "color": "red"}, {"text": "  ", "color": "white"}, {"nbt": "Pos", "entity": "@s", "color": "aqua"}]
tag @s remove mobcensus.viewer
