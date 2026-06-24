# Show only UNATTENDED cap clusters: ones fully loaded with no player within
# 128 blocks, i.e. likely running in a chunk loader. Differentiates a portal /
# force-chunk loader from an ender-pearl stasis chamber, across all dimensions.
#
# Unlike hotspots (which only ever sees player-adjacent cap-eaters), this scans
# every loaded cap mob, so genuinely unattended clusters are visible. Results
# are also written to storage mobcensus:find loaders for RCON.
#
# Cost: three dimension passes (one mob scan + one scan per cluster each).
# No per-tick work; only runs when called.
function mobcensus:_loaders with storage mobcensus:config
