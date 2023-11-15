extends Annotation
class_name VectorAnnotation

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
