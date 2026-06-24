# Run as the seed mob, at its position. Arg: clustersize (from mobcensus:tmp).
# Counts cap-eaters within clustersize blocks, records the hotspot, tracks the
# biggest, prints a click-to-teleport line, then drops them from the pool.
scoreboard players add #idx mobcensus 1
$execute store result score #count mobcensus if entity @e[tag=mobcensus.cap, distance=..$(clustersize)]

data modify storage mobcensus:find clusters append value {}
execute store result storage mobcensus:find clusters[-1].cluster int 1 run scoreboard players get #idx mobcensus
execute store result storage mobcensus:find clusters[-1].count int 1 run scoreboard players get #count mobcensus
data modify storage mobcensus:find clusters[-1].pos set from entity @s Pos

execute if score #count mobcensus > #max mobcensus run scoreboard players operation #max mobcensus = #count mobcensus
execute if score #count mobcensus >= #max mobcensus run data modify storage mobcensus:find biggest.pos set from entity @s Pos

# Build a clickable teleport line (integer coords for the /tp command).
execute store result storage mobcensus:tmp ln.x int 1 run data get entity @s Pos[0]
execute store result storage mobcensus:tmp ln.y int 1 run data get entity @s Pos[1]
execute store result storage mobcensus:tmp ln.z int 1 run data get entity @s Pos[2]
execute store result storage mobcensus:tmp ln.count int 1 run scoreboard players get #count mobcensus
execute store result storage mobcensus:tmp ln.idx int 1 run scoreboard players get #idx mobcensus
function mobcensus:_emit_line with storage mobcensus:tmp ln

$tag @e[tag=mobcensus.cap, distance=..$(clustersize)] remove mobcensus.cap
