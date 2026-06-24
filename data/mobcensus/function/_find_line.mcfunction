# Macro: x, y, z, dim. Executor is still the mob, so {"selector":"@s"} names it.
# The teleport is dimension-aware so it also works for cross-dimension results.
$tellraw @a[tag=mobcensus.viewer] ["", {"selector": "@s", "color": "red"}, {"text": "  ", "color": "white"}, {"text": "[tp $(x) $(y) $(z)]", "color": "aqua", "underlined": true, "click_event": {"action": "run_command", "command": "/execute in $(dim) run tp @s $(x) $(y) $(z)"}, "hover_event": {"action": "show_text", "value": "Teleport to $(dim) $(x) $(y) $(z)"}}]
