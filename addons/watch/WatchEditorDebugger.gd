extends EditorDebuggerPlugin
class_name WatchEditorDebugger

var plugin: WatchPlugin

func _has_capture(prefix):
	return prefix == "watch"

func _capture(message, data, session_id):
	if message == "watch:watch":
		var source = data[0]
		var line = data[1]
		var value = data[2]
		plugin.on_watch(source, line, value)
		# we handled the message
		return true
