# Macro: radius, region, name, key. Runs positioned at 0 320 0 inside one
# dimension (so @a[distance=..huge] matches only that dimension's players).
# Computes fill, estimated cap, and percent, stores them, and prints a line.

# Players in this dimension.
execute store result score #players mobcensus if entity @a[distance=..100000000]

# Count separated player groups (regions).
scoreboard players set #regions mobcensus 0
tag @a[distance=..100000000] add mobcensus.rseed
function mobcensus:_region_step with storage mobcensus:tmp capargs
tag @a remove mobcensus.rseed

# Estimated cap = 70 per region (see cap.mcfunction header for the math).
scoreboard players set #per mobcensus 70
scoreboard players operation #cap mobcensus = #regions mobcensus
scoreboard players operation #cap mobcensus *= #per mobcensus

# Fill = non-persistent cap_mobs within radius of any player here.
tag @e remove mobcensus.cap
$execute as @a[distance=..100000000] at @s run tag @e[type=#mobcensus:cap_mobs, distance=..$(radius), nbt=!{PersistenceRequired:1b}] add mobcensus.cap
execute store result score #fill mobcensus if entity @e[tag=mobcensus.cap]
tag @e remove mobcensus.cap

# Percent = 100 * fill / cap (guarded).
scoreboard players operation #pct mobcensus = #fill mobcensus
scoreboard players set #hundred mobcensus 100
scoreboard players operation #pct mobcensus *= #hundred mobcensus
execute if score #cap mobcensus matches 1.. run scoreboard players operation #pct mobcensus /= #cap mobcensus
execute unless score #cap mobcensus matches 1.. run scoreboard players set #pct mobcensus 0

# Persist for RCON.
$execute store result storage mobcensus:find cap.$(key).fill int 1 run scoreboard players get #fill mobcensus
$execute store result storage mobcensus:find cap.$(key).cap int 1 run scoreboard players get #cap mobcensus
$execute store result storage mobcensus:find cap.$(key).percent int 1 run scoreboard players get #pct mobcensus
$execute store result storage mobcensus:find cap.$(key).players int 1 run scoreboard players get #players mobcensus
$execute store result storage mobcensus:find cap.$(key).regions int 1 run scoreboard players get #regions mobcensus

# Report a line only for dimensions that have players.
$execute if score #players mobcensus matches 1.. run tellraw @a ["", {"text": "$(name) monster cap: ", "color": "gold"}, {"score": {"name": "#fill", "objective": "mobcensus"}, "color": "yellow"}, {"text": " / ", "color": "gray"}, {"score": {"name": "#cap", "objective": "mobcensus"}, "color": "yellow"}, {"text": "  (", "color": "gray"}, {"score": {"name": "#pct", "objective": "mobcensus"}, "color": "aqua"}, {"text": "%)", "color": "gray"}]
