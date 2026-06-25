# Macro body for loaders. Args from mobcensus:config (clustersize used).
tag @s add mobcensus.viewer
scoreboard players set #suspect_total mobcensus 0
data modify storage mobcensus:find clusters set value []
data modify storage mobcensus:find loaders set value []
$data modify storage mobcensus:tmp clustersize set value $(cluster)

tellraw @a[tag=mobcensus.viewer] ["", {"text": "-- unattended (loader-suspect) clusters - all dimensions, worst first --", "color": "gold"}]

# Tag every loaded, non-persistent cap mob across ALL dimensions (a bare @e is
# not dimension-scoped; clustering is distance-filtered so groups stay
# in-dimension). Loader-suspect classification happens in _cluster_emit.
tag @e remove mobcensus.cap
tag @e[type=#mobcensus:cap_mobs, nbt=!{PersistenceRequired:1b}] add mobcensus.cap
function mobcensus:_cluster_step
function mobcensus:_sort_clusters
scoreboard players set #pi mobcensus 0
scoreboard players set #print_loaders mobcensus 1
function mobcensus:_print_clusters

execute if score #suspect_total mobcensus matches 0 run tellraw @a[tag=mobcensus.viewer] ["", {"text": "  none found - no unattended cap clusters", "color": "gray"}]
execute if score #suspect_total mobcensus matches 1.. run tellraw @a[tag=mobcensus.viewer] ["", {"text": "  ", "color": "gray"}, {"score": {"name": "#suspect_total", "objective": "mobcensus"}, "color": "yellow"}, {"text": " unattended cluster(s) - storage mobcensus:find loaders", "color": "gray"}]

tag @e remove mobcensus.cap
tag @s remove mobcensus.viewer
