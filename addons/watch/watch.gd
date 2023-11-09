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
	
	static func is_instance(annotation: Annotation) -> bool:
		return false

	static func can_display(value: Variant) -> bool:
		return false
		
	func copy_settings_from(other: Annotation):
		line = other.line
		text_edit = other.text_edit

	func is_valid():
		return is_watch_valid()

	func is_watch_valid() -> bool:
		return text_edit.get_line(line).contains("watch(")

	func create():
		pass
	
	func get_line_height():
		return text_edit.get_line_height() - text_edit.get_theme_constant("line_spacing")
	
	func get_line_height_square():
		var line_height = get_line_height()
		return Vector2(line_height, line_height)

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

	func update_value(value: Variant):
		pass

class TextAnnotation extends Annotation:
	static func name():
		return "Text"
		
	static func is_instance(annotation: Annotation) -> bool:
		return annotation is TextAnnotation

	static func can_display(value: Variant) -> bool:
		return true
	
	func create():
		node = RichTextLabel.new()
		node.fit_content = true
		node.text_direction = Control.TEXT_DIRECTION_LTR
		node.autowrap_mode = TextServer.AUTOWRAP_OFF
		node.add_theme_font_size_override("normal_font_size", 30)
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Color.TRANSPARENT
		node.add_theme_stylebox_override("normal", style_box)
	
	func update_value(value: Variant):
		node.text = str(value)

class ColorAnnotation extends Annotation:
	static func name():
		return "Color"
		
	static func is_instance(annotation: Annotation) -> bool:
		return annotation is ColorAnnotation

	static func can_display(value: Variant) -> bool:
		return value is Color

	func create():
		node = ColorRect.new()
		node.set_size(get_line_height_square())
	
	func update_value(value: Variant):
		node.color = value

class VectorAnnotation extends Annotation:
	static func name():
		return "Vector"
	
	static func is_instance(annotation: Annotation) -> bool:
		return annotation is VectorAnnotation
	
	static func can_display(value: Variant) -> bool:
		return value is Vector2
	
	func create():
		node = VectorDisplay.new()
		node.set_size(get_line_height_square())
	
	func update_value(value: Variant):
		node.value = value
		node.queue_redraw()

class VectorDisplay extends Control:
	var value: Vector2
	
	func _draw():
		var rect = get_rect()
		var start = rect.size / 2
		var length = min(rect.size.x, rect.size.y) 
		var pointer = value.normalized() * length
		var end = start + pointer
		var right_tip = end + pointer.rotated(PI * 3 / 4) / 3
		var left_tip = end + pointer.rotated(-PI * 3 / 4) / 3
		draw_line(start, end, Color.WHITE, 2.0, true)
		draw_line(end, right_tip, Color.WHITE, 2.0, true)
		draw_line(end, left_tip, Color.WHITE, 2.0, true)

const annotation_classes = [ColorAnnotation, VectorAnnotation, TextAnnotation]

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

		var annotation = Annotation.new()
		annotation.text_edit = text_edit
		annotation.node = null
		annotation.line = line - 1 # Godot source uses 1-indexing, TextEdit uses 0-indexing
		if not annotation.is_watch_valid():
			return
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
			var annotation_class = find_annotation_class()
			if annotation_class == null:
				remove_annotation()
				return
			if not annotation_class.is_instance(current_annotation):
				print(annotation_class)
				var new_annotation = annotation_class.new()
				new_annotation.copy_settings_from(current_annotation)
				new_annotation.create()
				current_annotation.text_edit.add_child(new_annotation.node)
				remove_annotation()
				current_annotation = new_annotation
			current_annotation.update_value(current_value)
	
	func find_annotation_class():
		for annotation_class in annotation_classes:
			if annotation_class.can_display(current_value):
				return annotation_class
		return null

	func remove_annotation():
		if current_annotation == null:
			return
		current_annotation.node.queue_free()
		current_annotation = null
