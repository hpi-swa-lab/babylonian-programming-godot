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
	add_play_snapshot_button()

func _exit_tree():
	remove_debugger_plugin(debugger)
	remove_autoload_singleton("B")
	remove_autoload_singleton("InGameUI")
	remove_play_snapshot_button()

func on_session_ready(session_id: int):
	in_game_ui.on_session_ready(session_id)

var play_snapshot_button: Control
const play_snapshot_button_container = CONTAINER_TOOLBAR

func add_play_snapshot_button():
	play_snapshot_button = Button.new()
	play_snapshot_button.text = "Play Snapshot"
	play_snapshot_button.pressed.connect(self.play_snapshot)
	add_control_to_container(play_snapshot_button_container, play_snapshot_button)

func play_snapshot():
	get_editor_interface().play_custom_scene("res://addons/watch/snapshots/snapshot_loader.tscn")

func remove_play_snapshot_button():
	remove_control_from_container(play_snapshot_button_container, play_snapshot_button)
	play_snapshot_button.queue_free()

func _on_gui_focus_changed(node: Node):
	if node is TextEdit:
		watch_manager.current_parent = node

func _process(delta):
	watch_manager.update()
