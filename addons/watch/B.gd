extends Node

var watch_manager = WatchManager.new()

func _ready():
	watch_manager.current_parent = $/root

func _process(delta):
	watch_manager.update()

func watch(value: Variant):
	var stack = get_stack()
	if len(stack) < 1:
		print("Watching is unsupported without access to a stack")
		return
	var location = stack[1] # get the caller
	var source = location["source"]
	var line = location["line"]
	var data = [source, line, value]
	EngineDebugger.send_message("watch:watch", data)
	watch_manager.on_watch(source, line, value)
	return value
