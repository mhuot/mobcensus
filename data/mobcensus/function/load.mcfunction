# Announced once on (re)load
scoreboard objectives add mobcensus dummy
tellraw @a ["", {"text": "[mobcensus] ", "color": "gold"}, {"text": "mob finder ready - run ", "color": "gray"}, {"text": "/function mobcensus:help", "color": "yellow"}]
