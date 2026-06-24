# Run as a hostile mob. Extracts integer coords + dimension, then prints a
# dimension-aware click-to-teleport line via the macro helper.
execute store result storage mobcensus:tmp fl.x int 1 run data get entity @s Pos[0]
execute store result storage mobcensus:tmp fl.y int 1 run data get entity @s Pos[1]
execute store result storage mobcensus:tmp fl.z int 1 run data get entity @s Pos[2]
data modify storage mobcensus:tmp fl.dim set from entity @s Dimension
function mobcensus:_find_line with storage mobcensus:tmp fl
