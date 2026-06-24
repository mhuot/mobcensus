# Cap-eating hostiles, grouped by where they are bunched up ("hotspots").
#
# Scoped to the runner's dimension on purpose: the hostile mob cap is
# per-dimension. We tag non-persistent hostile mobs within 128 blocks of any
# player in this dimension (a close approximation of the mobs counting toward
# the monster cap), then greedily group them into 16-block clusters.
tag @s add mobcensus.viewer
scoreboard players set #idx mobcensus 0
scoreboard players set #max mobcensus 0
data modify storage mobcensus:find clusters set value []
data modify storage mobcensus:find biggest set value {}

# Build the cap-eating set. @a[distance=..1.0E8] only matches players in the
# execution dimension (cross-dimension distance is undefined), so this stays
# scoped to the dimension being inspected.
tag @e remove mobcensus.cap
execute as @a[distance=..1.0E8] at @s run tag @e[type=#mobcensus:hostiles, distance=..128, nbt=!{PersistenceRequired:1b}] add mobcensus.cap
execute store result score #total mobcensus if entity @e[tag=mobcensus.cap]

tellraw @a[tag=mobcensus.viewer] ["", {"text": "-- cap-eating hostiles: ", "color": "gold"}, {"score": {"name": "#total", "objective": "mobcensus"}, "color": "yellow"}, {"text": " (this dimension), grouped by hotspot --", "color": "gold"}]

# Emit one cluster per seed until none remain.
function mobcensus:_cluster_step

execute if score #total mobcensus matches 0 run tellraw @a[tag=mobcensus.viewer] ["", {"text": "  none - no players are loading hostile spawns here right now", "color": "gray"}]
execute if score #total mobcensus matches 1.. run tellraw @a[tag=mobcensus.viewer] ["", {"text": "  >> biggest hotspot: ", "color": "gold"}, {"score": {"name": "#max", "objective": "mobcensus"}, "color": "red"}, {"text": " mobs near ", "color": "gray"}, {"storage": "mobcensus:find", "nbt": "biggest.pos", "color": "aqua"}]

# Cleanup (this dimension).
tag @e remove mobcensus.cap
tag @s remove mobcensus.viewer
