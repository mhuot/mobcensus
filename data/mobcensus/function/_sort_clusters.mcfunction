# Selection-sort mobcensus:find clusters in place, descending by count. Repeatedly
# extracts the largest remaining cluster into a scratch list, then swaps it back.
# O(n^2) in cluster count, which stays small.
data modify storage mobcensus:find sorted set value []
function mobcensus:_sort_extract_loop
data modify storage mobcensus:find clusters set from storage mobcensus:find sorted
data remove storage mobcensus:find sorted
