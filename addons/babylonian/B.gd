extends Node

var probe_manager = ProbeManager.new()

func _ready():
	probe_manager.current_parent = InGameUI

func _process(delta):
	probe_manager.update()

func _exit_tree():
	probe_manager.on_exit()

func get_caller_stack_frame():
	var stack = get_stack()
	if len(stack) == 0:
		return null
	var location = null
	var here = stack[0]["source"]
	for frame in stack:
		if frame["source"] != here:
			return frame
	return stack[len(stack) - 1]

func probe(value: Variant, group = null, show_in_game = false):
	var location = get_caller_stack_frame()
	if location == null:
		print("Probing is unsupported without access to a stack")
		return value
	var source = location["source"]
	var line = location["line"]
	var sent_group = Utils.group_key(group)
	var data = [source, line, value, sent_group]
	EngineDebugger.send_message("babylonian:probe", data)
	if show_in_game:
		probe_manager.on_probe(source, line, value, group)
	return value

func game_probe(value: Variant, group = null):
	return probe(value, group, true)
