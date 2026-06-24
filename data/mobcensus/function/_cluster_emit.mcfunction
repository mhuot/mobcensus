# Run as the seed mob, at its position. Arg: clustersize (from mobcensus:tmp).
# Counts cap-eaters within clustersize blocks, records the hotspot, flags
# whether it looks unattended (loader-suspect), tracks the biggest, prints the
# appropriate line, then drops the cluster from the pool.
scoreboard players add #idx mobcensus 1
$execute store result score #count mobcensus if entity @e[tag=mobcensus.cap, distance=..$(clustersize)]

data modify storage mobcensus:find clusters append value {}
execute store result storage mobcensus:find clusters[-1].cluster int 1 run scoreboard players get #idx mobcensus
execute store result storage mobcensus:find clusters[-1].count int 1 run scoreboard players get #count mobcensus
data modify storage mobcensus:find clusters[-1].pos set from entity @s Pos

# Loader-suspect detection at the cluster anchor (@s, native dimension context).
# No player within 128 blocks -> unattended; an ender pearl ticking nearby
# implies a stasis chamber, otherwise a portal / force-chunk loader.
scoreboard players set #suspect mobcensus 1
execute if entity @a[distance=..128] run scoreboard players set #suspect mobcensus 0
execute store result storage mobcensus:find clusters[-1].loader_suspect byte 1 run scoreboard players get #suspect mobcensus
data modify storage mobcensus:find clusters[-1].origin_type set value "portal_loader"
execute if score #suspect mobcensus matches 0 run data modify storage mobcensus:find clusters[-1].origin_type set value "player_present"
execute if score #suspect mobcensus matches 1 if entity @e[type=minecraft:ender_pearl, distance=..128] run data modify storage mobcensus:find clusters[-1].origin_type set value "stasis_chamber"

execute if score #count mobcensus > #max mobcensus run scoreboard players operation #max mobcensus = #count mobcensus
execute if score #count mobcensus >= #max mobcensus run data modify storage mobcensus:find biggest.pos set from entity @s Pos

# Build the teleport-line payload (integer coords for the /tp command).
execute store result storage mobcensus:tmp ln.x int 1 run data get entity @s Pos[0]
execute store result storage mobcensus:tmp ln.y int 1 run data get entity @s Pos[1]
execute store result storage mobcensus:tmp ln.z int 1 run data get entity @s Pos[2]
execute store result storage mobcensus:tmp ln.count int 1 run scoreboard players get #count mobcensus
execute store result storage mobcensus:tmp ln.idx int 1 run scoreboard players get #idx mobcensus
data modify storage mobcensus:tmp ln.origin set from storage mobcensus:find clusters[-1].origin_type

# Output. hotspots mode (#loaders_mode 0): every cluster, standard line
# (unchanged). loaders mode (#loaders_mode 1): only unattended clusters, with
# an origin label, also collected into storage mobcensus:find loaders.
execute if score #loaders_mode mobcensus matches 0 run function mobcensus:_emit_line with storage mobcensus:tmp ln
execute if score #loaders_mode mobcensus matches 1 if score #suspect mobcensus matches 1 run scoreboard players add #suspect_total mobcensus 1
execute if score #loaders_mode mobcensus matches 1 if score #suspect mobcensus matches 1 run data modify storage mobcensus:find loaders append from storage mobcensus:find clusters[-1]
execute if score #loaders_mode mobcensus matches 1 if score #suspect mobcensus matches 1 run function mobcensus:_loader_line with storage mobcensus:tmp ln

$tag @e[tag=mobcensus.cap, distance=..$(clustersize)] remove mobcensus.cap
