# Macro: i. Read clusters[i].count into score #scount.
$execute store result score #scount mobcensus run data get storage mobcensus:find clusters[$(i)].count
