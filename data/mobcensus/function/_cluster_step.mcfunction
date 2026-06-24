# Recursive driver: emit one hotspot per remaining seed, then recurse.
# Terminates because _cluster_emit always untags at least its own seed.
execute unless entity @e[tag=mobcensus.cap] run return 0
execute as @e[tag=mobcensus.cap, limit=1] at @s run function mobcensus:_cluster_emit
function mobcensus:_cluster_step
