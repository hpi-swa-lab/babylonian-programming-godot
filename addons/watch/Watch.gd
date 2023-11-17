class_name Watch

var annotation_classes = [ColorAnnotation, FloatAnnotation, VectorAnnotation, TextAnnotation]

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

func create_annotation(text_edit: TextEdit):
	if not belongs_to_current_script() or current_annotation != null:
		return

	# Godot source uses 1-indexing, TextEdit uses 0-indexing
	var new_annotation = Annotation.new(line - 1, text_edit)
	if not new_annotation.is_watch_valid():
		return
	current_annotation = new_annotation

	update_annotation_display()

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

func update_annotation_class():
	var annotation_class = find_annotation_class()
	if annotation_class == null:
		remove_annotation()
		return
	if not annotation_class.is_instance(current_annotation):
		var new_annotation = Annotation.from(current_annotation, annotation_class)
		current_annotation.text_edit.add_child(new_annotation.node)
		remove_annotation()
		current_annotation = new_annotation

func update_annotation_display():
	if current_annotation != null:
		update_annotation_class()
		current_annotation.update_value(current_value)

func find_annotation_class():
	for annotation_class in annotation_classes:
		if annotation_class.can_display(current_value):
			return annotation_class
	return null

func remove_annotation():
	if current_annotation == null:
		return
	if current_annotation.node != null:
		current_annotation.node.queue_free()
	current_annotation = null
