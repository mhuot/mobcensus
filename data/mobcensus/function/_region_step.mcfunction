# Macro: region. Greedily counts player groups: each step claims one seed and
# removes every player within `region` blocks of it, then recurses.
execute unless entity @a[tag=mobcensus.rseed] run return 0
scoreboard players add #regions mobcensus 1
$execute as @a[tag=mobcensus.rseed, limit=1] at @s run tag @a[tag=mobcensus.rseed, distance=..$(region)] remove mobcensus.rseed
function mobcensus:_region_step with storage mobcensus:tmp capargs
