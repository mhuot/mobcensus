# Per-type hostile counts written to storage mobcensus:find counts.
# RCON-friendly: run this, then `data get storage mobcensus:find counts`.
data modify storage mobcensus:find counts set value {}
execute store result storage mobcensus:find counts.total int 1 if entity @e[type=#mobcensus:cap_mobs]
execute store result storage mobcensus:find counts.zombie int 1 if entity @e[type=minecraft:zombie]
execute store result storage mobcensus:find counts.husk int 1 if entity @e[type=minecraft:husk]
execute store result storage mobcensus:find counts.drowned int 1 if entity @e[type=minecraft:drowned]
execute store result storage mobcensus:find counts.skeleton int 1 if entity @e[type=minecraft:skeleton]
execute store result storage mobcensus:find counts.creeper int 1 if entity @e[type=minecraft:creeper]
execute store result storage mobcensus:find counts.spider int 1 if entity @e[type=minecraft:spider]
execute store result storage mobcensus:find counts.cave_spider int 1 if entity @e[type=minecraft:cave_spider]
execute store result storage mobcensus:find counts.enderman int 1 if entity @e[type=minecraft:enderman]
execute store result storage mobcensus:find counts.witch int 1 if entity @e[type=minecraft:witch]
execute store result storage mobcensus:find counts.slime int 1 if entity @e[type=minecraft:slime]
execute store result storage mobcensus:find counts.phantom int 1 if entity @e[type=minecraft:phantom]
execute store result storage mobcensus:find counts.zombified_piglin int 1 if entity @e[type=minecraft:zombified_piglin]
execute store result storage mobcensus:find counts.piglin int 1 if entity @e[type=minecraft:piglin]
execute store result storage mobcensus:find counts.ghast int 1 if entity @e[type=minecraft:ghast]
execute store result storage mobcensus:find counts.magma_cube int 1 if entity @e[type=minecraft:magma_cube]
data get storage mobcensus:find counts
