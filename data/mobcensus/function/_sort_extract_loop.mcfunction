# Move the largest remaining cluster into 'sorted', repeat until none remain.
execute store result score #slen mobcensus run data get storage mobcensus:find clusters
execute if score #slen mobcensus matches 0 run return 0
scoreboard players set #si mobcensus 0
scoreboard players set #smax mobcensus -1
scoreboard players set #smaxi mobcensus 0
function mobcensus:_sort_findmax_loop
execute store result storage mobcensus:tmp s.i int 1 run scoreboard players get #smaxi mobcensus
function mobcensus:_sort_move with storage mobcensus:tmp s
function mobcensus:_sort_extract_loop
