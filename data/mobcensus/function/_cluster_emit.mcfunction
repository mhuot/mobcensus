# Run as the seed mob, at its position. Arg: clustersize (from mobcensus:tmp).
# Builds one cluster record in mobcensus:find clusters - NO printing; hotspots /
# loaders sort the list and print afterwards. Then drops the cluster from the
# pool. Cost: one entity scan per cluster.
$execute store result score #count mobcensus if entity @e[tag=mobcensus.cap, distance=..$(clustersize)]
data modify storage mobcensus:find clusters append value {}
execute store result storage mobcensus:find clusters[-1].count int 1 run scoreboard players get #count mobcensus
data modify storage mobcensus:find clusters[-1].pos set from entity @s Pos
execute store result storage mobcensus:find clusters[-1].x int 1 run data get entity @s Pos[0]
execute store result storage mobcensus:find clusters[-1].y int 1 run data get entity @s Pos[1]
execute store result storage mobcensus:find clusters[-1].z int 1 run data get entity @s Pos[2]

# Loader-suspect classification at the cluster anchor (@s).
scoreboard players set #suspect mobcensus 1
execute if entity @a[distance=..128] run scoreboard players set #suspect mobcensus 0
execute store result storage mobcensus:find clusters[-1].loader_suspect byte 1 run scoreboard players get #suspect mobcensus
data modify storage mobcensus:find clusters[-1].origin_type set value "portal_loader"
execute if score #suspect mobcensus matches 0 run data modify storage mobcensus:find clusters[-1].origin_type set value "player_present"
execute if score #suspect mobcensus matches 1 if entity @e[type=minecraft:ender_pearl, distance=..128] run data modify storage mobcensus:find clusters[-1].origin_type set value "stasis_chamber"

$tag @e[tag=mobcensus.cap, distance=..$(clustersize)] remove mobcensus.cap
