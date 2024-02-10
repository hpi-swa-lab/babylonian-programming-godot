class_name ProbeEditorDebugger extends EditorDebuggerPlugin

var plugin: BabylonianPlugin

func _has_capture(prefix):
	return prefix == "babylonian"

func send_message_to(session_id: int, message: String, data: Array):
	get_session(session_id).send_message(message, data)

func _capture(message, data, session_id):
	if message == "babylonian:probe":
		var source = data[0]
		var line = data[1]
		var value = data[2]
		var group = data[3]
		plugin.probe_manager.on_probe(source, line, value, group)
		# we handled the message
		return true
