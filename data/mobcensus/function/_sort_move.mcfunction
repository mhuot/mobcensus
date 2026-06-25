# Macro: i. Append clusters[i] to 'sorted', then remove it from clusters.
$data modify storage mobcensus:find sorted append from storage mobcensus:find clusters[$(i)]
$data remove storage mobcensus:find clusters[$(i)]
