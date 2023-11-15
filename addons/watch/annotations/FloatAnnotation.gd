extends Annotation
class_name FloatAnnotation

static func name():
	return "Float"

static func is_instance(annotation: Annotation) -> bool:
	return annotation is FloatAnnotation

static func can_display(value: Variant) -> bool:
	return value is float or value is int

func create():
	node = FloatOverTimeDisplay.new()
	node.set_size(Vector2(300, 3 * get_line_height()))

func get_offset() -> Vector2:
	return Vector2(0, -get_line_height())

func update_value(value: Variant):
	node.append(value)
	node.queue_redraw()
