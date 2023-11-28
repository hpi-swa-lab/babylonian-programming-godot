@tool
extends EditorPlugin
class_name WatchPlugin

var watches: Array[Watch] = []
var current_text_edit: TextEdit = null
var debugger = WatchEditorDebugger.new()

func _enter_tree():
	# Initialization of the plugin goes here.
	get_viewport().gui_focus_changed.connect(self._on_gui_focus_changed)
	debugger.plugin = self
	add_debugger_plugin(debugger)
	add_autoload_singleton("B", "B.gd")

func _exit_tree():
	remove_debugger_plugin(debugger)
	remove_autoload_singleton("B")

func on_watch(source: String, line: int, value: Variant):
	var watch = find_or_create_watch_for(source, line)
	watch.update_value(value)

func find_or_create_watch_for(source: String, line: int) -> Watch:
	for watch in watches:
		if watch.source == source and watch.line == line:
			if current_text_edit != null:
				watch.create_annotation(current_text_edit)
			return watch
	var watch = Watch.new()
	watch.source = source
	watch.line = line
	watch.plugin = self
	watches.append(watch)
	if current_text_edit != null:
		watch.create_annotation(current_text_edit)
	return watch

func _on_gui_focus_changed(node: Node):
	if node is TextEdit:
		if current_text_edit == node:
			return

		for watch in watches:
			watch.remove_annotation()

		for watch in watches:
			watch.create_annotation(node)
		current_text_edit = node

func _process(delta):
	var to_be_removed = []
	for index in range(len(watches)):
		var watch = watches[index]
		watch.update()
		if watch.to_be_removed:
			to_be_removed.append(index)
	for i in range(len(to_be_removed) - 1, 0, -1):
		var index = to_be_removed[i]
		swap_remove(watches, index)

static func swap_remove(array: Array, index: int):
	var last = len(array) - 1
	if index != last:
		array[index] = array[last]
	array.resize(last)
