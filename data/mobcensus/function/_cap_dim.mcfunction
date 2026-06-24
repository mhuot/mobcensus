# Macro: dim, name, key. Runs the per-dimension cap calc inside that dimension.
data modify storage mobcensus:tmp capargs set from storage mobcensus:config
$data modify storage mobcensus:tmp capargs.name set value "$(name)"
$data modify storage mobcensus:tmp capargs.key set value "$(key)"
$execute in $(dim) positioned 0.0 320.0 0.0 run function mobcensus:_cap_calc with storage mobcensus:tmp capargs
