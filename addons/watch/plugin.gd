@tool
extends EditorPlugin
class_name WatchPlugin

var watch_manager = WatchManager.new()
var debugger = WatchEditorDebugger.new()
var in_game_ui = preload("./InGameUI.gd").new()

func _enter_tree():
	# Initialization of the plugin goes here.
	get_viewport().gui_focus_changed.connect(self._on_gui_focus_changed)
	watch_manager.plugin = self
	debugger.plugin = self
	in_game_ui.debugger = debugger
	add_debugger_plugin(debugger)
	add_autoload_singleton("B", "B.gd")
	add_autoload_singleton("InGameUI", "InGameUI.gd")

func _exit_tree():
	remove_debugger_plugin(debugger)
	remove_autoload_singleton("B")
	remove_autoload_singleton("InGameUI")

func on_session_ready(session_id: int):
	in_game_ui.on_session_ready(session_id)

func _on_gui_focus_changed(node: Node):
	if node is TextEdit:
		watch_manager.current_parent = node

func _process(delta):
	watch_manager.update()
