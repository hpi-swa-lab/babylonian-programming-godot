extends Node

var watch_manager = WatchManager.new()

func _ready():
	watch_manager.current_parent = InGameUI

func _process(delta):
	watch_manager.update()

func _exit_tree():
	watch_manager.on_exit()

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

func watch(value: Variant, group = null, show_in_game = false):
	var location = get_caller_stack_frame()
	if location == null:
		print("Watching is unsupported without access to a stack")
		return value
	var source = location["source"]
	var line = location["line"]
	var sent_group = Utils.group_key(group)
	var data = [source, line, value, sent_group]
	EngineDebugger.send_message("watch:watch", data)
	if show_in_game:
		watch_manager.on_watch(source, line, value, group)
	return value

func game_watch(value: Variant, group = null):
	watch(value, group, true)
