# Macro body for hotspots. Args from mobcensus:config: radius, cluster, region.
tag @s add mobcensus.viewer
scoreboard players set #idx mobcensus 0
scoreboard players set #max mobcensus 0
data modify storage mobcensus:find clusters set value []
data modify storage mobcensus:find biggest set value {}
$data modify storage mobcensus:tmp clustersize set value $(cluster)

# Build the cap-eating set in THIS dimension. @a within a huge distance only
# matches same-dimension players (cross-dimension distance is undefined).
tag @e remove mobcensus.cap
$execute as @a[distance=..100000000] at @s run tag @e[type=#mobcensus:cap_mobs, distance=..$(radius), nbt=!{PersistenceRequired:1b}] add mobcensus.cap
execute store result score #total mobcensus if entity @e[tag=mobcensus.cap]

tellraw @a[tag=mobcensus.viewer] ["", {"text": "-- cap-eating hostiles: ", "color": "gold"}, {"score": {"name": "#total", "objective": "mobcensus"}, "color": "yellow"}, {"text": " (this dimension), worst first --", "color": "gold"}]

function mobcensus:_cluster_step

execute if score #total mobcensus matches 0 run tellraw @a[tag=mobcensus.viewer] ["", {"text": "  none - no players are loading hostile spawns here", "color": "gray"}]
execute if score #total mobcensus matches 1.. run tellraw @a[tag=mobcensus.viewer] ["", {"text": "  >> biggest hotspot: ", "color": "gold"}, {"score": {"name": "#max", "objective": "mobcensus"}, "color": "red"}, {"text": " mobs near ", "color": "gray"}, {"storage": "mobcensus:find", "nbt": "biggest.pos", "color": "aqua"}]

tag @e remove mobcensus.cap
tag @s remove mobcensus.viewer
