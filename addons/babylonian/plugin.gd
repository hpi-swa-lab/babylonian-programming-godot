@tool
class_name BabylonianPlugin extends EditorPlugin

var probe_manager = ProbeManager.new()
var debugger = ProbeEditorDebugger.new()
var in_game_ui = preload("./InGameUI.gd").new()

var singletons = ["B", "InGameUI"]

func _enter_tree():
	# Initialization of the plugin goes here.
	get_viewport().gui_focus_changed.connect(self._on_gui_focus_changed)
	probe_manager.plugin = self
	debugger.plugin = self
	add_debugger_plugin(debugger)
	for singleton in singletons:
		add_autoload_singleton(singleton, singleton + ".gd")
		
	# Halo initialization
	var selection = get_editor_interface().get_selection()
	selection.selection_changed.connect(_on_selection_changed)
	
func _on_selection_changed():
	var selection = get_editor_interface().get_selection()
	for node in selection.get_selected_nodes():
		print("Selected node: ", node.name)

func _exit_tree():
	probe_manager.on_exit()
	remove_debugger_plugin(debugger)
	for singleton in singletons:
		remove_autoload_singleton(singleton)

func _on_gui_focus_changed(node: Node):
	if node is TextEdit:
		handle_new_text_edit(node)

func handle_new_text_edit(text_edit: TextEdit):
	probe_manager.current_parent = text_edit
	add_wrap_in_probe_menu_item(text_edit)

const WRAP_IN_PROBE_ITEM_ID = 1000 # large enough to probably not conflict with anything else

func get_context_menu() -> PopupMenu:
	var script_text_editor = get_editor_interface().get_script_editor().get_current_editor()
	# the context menu is the only PopupMenu that is a direct child of the ScriptTextEditor
	for child in script_text_editor.get_children():
		if child is PopupMenu:
			return child
	return null

var registered_context_menus = []

func add_wrap_in_probe_menu_item(text_edit: TextEdit):
	var menu = get_context_menu()
	# only add listeners once
	if registered_context_menus.has(menu):
		return
	registered_context_menus.append(menu)

	menu.id_pressed.connect(
		func(id: int):
			if id == WRAP_IN_PROBE_ITEM_ID:
				wrap_selections_in_probe(text_edit))
	menu.about_to_popup.connect(
		func():
			menu.add_item("Wrap in probe", WRAP_IN_PROBE_ITEM_ID))

func wrap_selections_in_probe(text_edit: TextEdit):
	text_edit.start_action(TextEdit.ACTION_TYPING)
	text_edit.cut()
	text_edit.insert_text_at_caret("B.probe(")
	text_edit.paste()
	text_edit.insert_text_at_caret(")")
	text_edit.end_action()

func _process(delta):
	probe_manager.update()
