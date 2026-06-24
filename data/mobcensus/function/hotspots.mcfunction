# Cap-eating hostiles, grouped by where they are bunched up ("hotspots").
#
# Cap-accurate lane: tags non-persistent #mobcensus:cap_mobs within the
# configured spawn radius of any player, scoped to the runner's dimension
# (the monster cap is per-dimension), then greedily groups them into
# clusters of the configured size. Reported coordinates are click-to-teleport.
#
# Cost: one entity scan to build the set, then one scan per emitted cluster.
# No per-tick work; only runs when called.
function mobcensus:_hotspots with storage mobcensus:config
