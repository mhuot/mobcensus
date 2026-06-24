# Macro body for loaders. Args from mobcensus:config (clustersize used).
tag @s add mobcensus.viewer
scoreboard players set #idx mobcensus 0
scoreboard players set #max mobcensus 0
scoreboard players set #suspect_total mobcensus 0
scoreboard players set #loaders_mode mobcensus 1
data modify storage mobcensus:find clusters set value []
data modify storage mobcensus:find loaders set value []
data modify storage mobcensus:find biggest set value {}
$data modify storage mobcensus:tmp clustersize set value $(cluster)

tellraw @a[tag=mobcensus.viewer] ["", {"text": "-- unattended (loader-suspect) clusters - all dimensions --", "color": "gold"}]

# Tag every loaded, non-persistent cap mob across ALL dimensions. A bare @e is
# not dimension-scoped, so one pass covers every dimension; the clustering in
# _cluster_emit is distance-filtered, so each cluster is grouped within its own
# dimension. Loader-suspect classification happens per cluster in _cluster_emit.
tag @e remove mobcensus.cap
tag @e[type=#mobcensus:cap_mobs, nbt=!{PersistenceRequired:1b}] add mobcensus.cap
function mobcensus:_cluster_step

execute if score #suspect_total mobcensus matches 0 run tellraw @a[tag=mobcensus.viewer] ["", {"text": "  none found - no unattended cap clusters", "color": "gray"}]
execute if score #suspect_total mobcensus matches 1.. run tellraw @a[tag=mobcensus.viewer] ["", {"text": "  ", "color": "gray"}, {"score": {"name": "#suspect_total", "objective": "mobcensus"}, "color": "yellow"}, {"text": " unattended cluster(s) - storage mobcensus:find loaders", "color": "gray"}]

scoreboard players set #loaders_mode mobcensus 0
tag @e remove mobcensus.cap
tag @s remove mobcensus.viewer
