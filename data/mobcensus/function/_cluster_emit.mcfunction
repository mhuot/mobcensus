# Run as the seed mob, at its position. Counts cap-eaters within 16 blocks,
# records the hotspot, tracks the biggest, then drops them from the pool.
scoreboard players add #idx mobcensus 1
execute store result score #count mobcensus if entity @e[tag=mobcensus.cap, distance=..16]

data modify storage mobcensus:find clusters append value {}
execute store result storage mobcensus:find clusters[-1].cluster int 1 run scoreboard players get #idx mobcensus
execute store result storage mobcensus:find clusters[-1].count int 1 run scoreboard players get #count mobcensus
data modify storage mobcensus:find clusters[-1].pos set from entity @s Pos

# Track the largest hotspot for the summary line.
execute if score #count mobcensus > #max mobcensus run scoreboard players operation #max mobcensus = #count mobcensus
execute if score #count mobcensus >= #max mobcensus run data modify storage mobcensus:find biggest.pos set from entity @s Pos

tellraw @a[tag=mobcensus.viewer] ["", {"text": "  #", "color": "gold"}, {"score": {"name": "#idx", "objective": "mobcensus"}, "color": "yellow"}, {"text": "  ", "color": "white"}, {"score": {"name": "#count", "objective": "mobcensus"}, "color": "red"}, {"text": " mobs near ", "color": "gray"}, {"nbt": "Pos", "entity": "@s", "color": "aqua"}]

tag @e[tag=mobcensus.cap, distance=..16] remove mobcensus.cap
