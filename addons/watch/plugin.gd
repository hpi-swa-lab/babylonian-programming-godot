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
		handle_new_text_edit(node)

func handle_new_text_edit(text_edit: TextEdit):
	watch_manager.current_parent = text_edit
	add_wrap_in_watch_menu_item(text_edit)

const WRAP_IN_WATCH_ITEM_ID = 1000 # large enough to probably not conflict with anything else

func get_context_menu() -> PopupMenu:
	var script_text_editor = get_editor_interface().get_script_editor().get_current_editor()
	# the context menu is the only PopupMenu that is a direct child of the ScriptTextEditor
	for child in script_text_editor.get_children():
		if child is PopupMenu:
			return child
	return null

var registered_context_menus = []

func add_wrap_in_watch_menu_item(text_edit: TextEdit):
	var menu = get_context_menu()
	# only add listeners once
	if registered_context_menus.has(menu):
		return
	registered_context_menus.append(menu)

	menu.id_pressed.connect(
		func(id: int):
			if id == WRAP_IN_WATCH_ITEM_ID:
				wrap_selections_in_watch(text_edit))
	menu.about_to_popup.connect(
		func():
			menu.add_item("Wrap in watch", WRAP_IN_WATCH_ITEM_ID))

func wrap_selections_in_watch(text_edit: TextEdit):
	text_edit.start_action(TextEdit.ACTION_TYPING)
	text_edit.cut()
	text_edit.insert_text_at_caret("B.watch(")
	text_edit.paste()
	text_edit.insert_text_at_caret(")")
	text_edit.end_action()

func _process(delta):
	watch_manager.update()
