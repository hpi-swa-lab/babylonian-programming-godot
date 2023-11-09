@tool
extends EditorPlugin
class_name WatchPlugin

var watches: Array[Watch] = []

var current_text_edit: TextEdit = null

func global_watch(value: Variant):
	pass

class WatchEditorDebugger extends EditorDebuggerPlugin:
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

var debugger = WatchEditorDebugger.new()

func _enter_tree():
	# Initialization of the plugin goes here.
	get_viewport().connect("gui_focus_changed", Callable(self, "_on_gui_focus_changed"))
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
		for watch in watches:
			watch.remove_annotation()

		for watch in watches:
			watch.create_annotation(node)
		current_text_edit = node
	else:
		current_text_edit = null

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

const ANNOTATION_OFFSET = Vector2(40, 0)

class Annotation:
	var line = 0
	var text_edit: TextEdit
	var node: Control
	var last_scroll_pos
	var last_column

	func is_valid():
		return is_instance_valid(node) and is_watch_valid()

	func is_watch_valid() -> bool:
		return text_edit.get_line(line).contains("watch(")
		
	func update():
		var column = len(text_edit.get_line(line))
		if text_edit.scroll_vertical == last_scroll_pos and last_column == column:
			return
		last_scroll_pos = text_edit.scroll_vertical
		last_column = column
		var rect = text_edit.get_rect_at_line_column(line, column)
		if rect.position.y >= 0:
			node.show()
			node.set_position(Vector2(rect.end.x, rect.position.y) + ANNOTATION_OFFSET)
		else:
			node.hide()

class Watch:
	var source: String
	var line: int
	var current_value: Variant
	var current_annotation: Annotation
	var plugin: EditorPlugin
	var to_be_removed = false

	func belongs_to_current_script() -> bool:
		var current_script = plugin.get_editor_interface().get_script_editor().get_current_script()
		if current_script == null:
			return false
		return current_script.resource_path == source

	func create_annotation(text_edit: TextEdit) -> Annotation:
		if not belongs_to_current_script() or current_annotation != null:
			return

		var text_label = RichTextLabel.new()
		text_label.fit_content = true
		text_label.text_direction = Control.TEXT_DIRECTION_LTR
		text_label.autowrap_mode = TextServer.AUTOWRAP_OFF

		var annotation = Annotation.new()
		annotation.text_edit = text_edit
		annotation.node = text_label
		annotation.line = line - 1 # Godot source uses 1-indexing, TextEdit uses 0-indexing
		if not annotation.is_watch_valid():
			return

		text_edit.add_child(text_label)
		annotation.update()

		current_annotation = annotation
		update_annotation_display()
		return annotation

	func update():
		if current_annotation != null:
			if current_annotation.is_valid():
				current_annotation.update()
			else:
				remove_annotation()
				if belongs_to_current_script():
					to_be_removed = true

	func update_value(new_value: Variant):
		current_value = new_value
		update_annotation_display()

	func update_annotation_display():
		if current_annotation != null:
			current_annotation.node.text = str(current_value)

	func remove_annotation():
		if current_annotation == null:
			return
		current_annotation.node.queue_free()
		current_annotation = null
