# Runs on (re)load and world load.
scoreboard objectives add mobcensus dummy

# Config defaults - only set when absent, so user changes survive reloads.
execute unless data storage mobcensus:config radius run data modify storage mobcensus:config radius set value 128
execute unless data storage mobcensus:config cluster run data modify storage mobcensus:config cluster set value 16
execute unless data storage mobcensus:config region run data modify storage mobcensus:config region set value 256

tellraw @a ["", {"text": "[mobcensus] ", "color": "gold"}, {"text": "ready - run ", "color": "gray"}, {"text": "/function mobcensus:help", "color": "yellow"}]
