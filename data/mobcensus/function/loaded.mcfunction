# Every loaded hostile across all dimensions (in-game use).
tag @s add mobcensus.viewer
execute store result storage mobcensus:find n int 1 if entity @e[type=#mobcensus:hostiles]
tellraw @a[tag=mobcensus.viewer] ["", {"text": "-- loaded hostiles (server-wide): ", "color": "gold"}, {"storage": "mobcensus:find", "nbt": "n", "color": "yellow"}, {"text": " --", "color": "gold"}]
execute as @e[type=#mobcensus:hostiles] run tellraw @a[tag=mobcensus.viewer] ["", {"selector": "@s", "color": "red"}, {"text": "  ", "color": "white"}, {"nbt": "Pos", "entity": "@s", "color": "aqua"}, {"text": "  ", "color": "white"}, {"nbt": "Dimension", "entity": "@s", "color": "dark_gray"}]
tag @s remove mobcensus.viewer
