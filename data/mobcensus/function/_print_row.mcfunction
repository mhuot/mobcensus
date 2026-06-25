# Macro: i. Emit the line for clusters[i] at rank #disp. hotspots prints every
# row; loaders prints only loader-suspect rows and collects them.
$data modify storage mobcensus:tmp ln set from storage mobcensus:find clusters[$(i)]
execute store result storage mobcensus:tmp ln.idx int 1 run scoreboard players get #disp mobcensus
data modify storage mobcensus:tmp ln.origin set from storage mobcensus:tmp ln.origin_type
execute store result score #rsusp mobcensus run data get storage mobcensus:tmp ln.loader_suspect
execute if score #print_loaders mobcensus matches 0 run function mobcensus:_emit_line with storage mobcensus:tmp ln
execute if score #print_loaders mobcensus matches 1 if score #rsusp mobcensus matches 1 run scoreboard players add #suspect_total mobcensus 1
execute if score #print_loaders mobcensus matches 1 if score #rsusp mobcensus matches 1 run data modify storage mobcensus:find loaders append from storage mobcensus:tmp ln
execute if score #print_loaders mobcensus matches 1 if score #rsusp mobcensus matches 1 run function mobcensus:_loader_line with storage mobcensus:tmp ln
