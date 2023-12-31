extends EditorDebuggerPlugin
class_name WatchEditorDebugger

var plugin: WatchPlugin

func _has_capture(prefix):
	return prefix == "watch" or prefix == plugin.in_game_ui.message_capture

func send_message_to(session_id: int, message: String, data: Array):
	get_session(session_id).send_message(message, data)

func _capture(message, data, session_id):
	if message == "watch:watch":
		var source = data[0]
		var line = data[1]
		var value = data[2]
		plugin.watch_manager.on_watch(source, line, value)
		# we handled the message
		return true
	if message == plugin.in_game_ui.message_capture + ":game_ready":
		plugin.on_session_ready(session_id)
		return true
