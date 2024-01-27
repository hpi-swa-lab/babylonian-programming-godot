extends Node
class_name WatchGroup

var annotation_classes = [ColorAnnotation, FloatAnnotation, VectorAnnotation, TextAnnotation]

var watch#: Watch
var group
var current_value: Variant
var current_annotation: Annotation
var to_be_removed = false

func create_annotation(parent: Node):
	if not watch.belongs_to_current_script() or current_annotation != null:
		return

	# Godot source uses 1-indexing, TextEdit uses 0-indexing
	var new_annotation = Annotation.new(watch.line - 1, parent, self)
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
			if watch.belongs_to_current_script():
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
		current_annotation.parent.add_child(new_annotation.display)
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
	if current_annotation.display != null:
		current_annotation.display.queue_free()
	current_annotation = null
