# Recursive driver: emit one hotspot per remaining seed, then recurse.
# Terminates because _cluster_emit always untags at least its own seed.
# Cost is one entity scan per cluster, not per mob.
execute unless entity @e[tag=mobcensus.cap] run return 0
execute as @e[tag=mobcensus.cap, limit=1] at @s run function mobcensus:_cluster_emit with storage mobcensus:tmp
function mobcensus:_cluster_step
