# Print the (already-sorted) clusters worst-first. #pi is the 0-based cursor;
# #print_loaders selects hotspots (0 = print every row) vs loaders (1 = only
# loader-suspect rows, also collected into mobcensus:find loaders).
execute store result score #plen mobcensus run data get storage mobcensus:find clusters
execute if score #pi mobcensus >= #plen mobcensus run return 0
scoreboard players operation #disp mobcensus = #pi mobcensus
scoreboard players add #disp mobcensus 1
execute store result storage mobcensus:tmp p.i int 1 run scoreboard players get #pi mobcensus
function mobcensus:_print_row with storage mobcensus:tmp p
scoreboard players add #pi mobcensus 1
function mobcensus:_print_clusters
