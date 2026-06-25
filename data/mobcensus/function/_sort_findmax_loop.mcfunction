# Scan clusters[] tracking the index of the largest count into #smaxi.
execute if score #si mobcensus >= #slen mobcensus run return 0
execute store result storage mobcensus:tmp f.i int 1 run scoreboard players get #si mobcensus
function mobcensus:_sort_readcount with storage mobcensus:tmp f
execute if score #scount mobcensus > #smax mobcensus run scoreboard players operation #smaxi mobcensus = #si mobcensus
execute if score #scount mobcensus > #smax mobcensus run scoreboard players operation #smax mobcensus = #scount mobcensus
scoreboard players add #si mobcensus 1
function mobcensus:_sort_findmax_loop
