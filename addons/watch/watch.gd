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
	for watch in watches:
		watch.update()

const ANNOTATION_OFFSET = Vector2(40, 0)

class Annotation:
	var line = 0
	var node: Control
	var last_scroll_pos
	var last_column

	func is_valid():
		return is_instance_valid(node) and is_watch_valid()

	func get_text_edit() -> TextEdit:
		return node.get_parent() as TextEdit

	func is_watch_valid() -> bool:
		return get_text_edit().get_line(line).contains("watch(")

	func update():
		var text_edit = get_text_edit()
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

	func set_line(line: int):
		self.line = line

	func set_node(node: Control):
		self.node = node

class Watch:
	var source: String
	var line: int
	var current_value: Variant
	var current_annotation: Annotation
	var plugin: EditorPlugin

	func belongs_to_text_edit(text_edit: TextEdit) -> bool:
		var current_script = plugin.get_editor_interface().get_script_editor().get_current_script()
		return current_script.resource_path == source

	func create_annotation(text_edit: TextEdit) -> Annotation:
		if not belongs_to_text_edit(text_edit):
			return

		var textLabel = RichTextLabel.new()
		textLabel.fit_content = true
		textLabel.text_direction = Control.TEXT_DIRECTION_LTR
		textLabel.autowrap_mode = TextServer.AUTOWRAP_OFF

		var annotation = Annotation.new()
		annotation.set_node(textLabel)
		annotation.set_line(line - 1) # Godot source uses 1-indexing, TextEdit uses 0-indexing
		text_edit.add_child(textLabel)
		annotation.update()

		current_annotation = annotation
		update_annotation_display()
		return annotation

	func update():
		if current_annotation != null:
			if current_annotation.is_valid():
				current_annotation.update()
			else:
				print("removing annotation")
				remove_annotation()

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
