class_name B

static func watch(value: Variant):
	var stack = get_stack()
	if len(stack) < 1:
		print("Watching is unsupported without access to a stack")
		return
	var location = stack[1] # get the caller
	var source = location["source"]
	var line = location["line"]
	var data = [source, line, value]
	EngineDebugger.send_message("watch:watch", data)
