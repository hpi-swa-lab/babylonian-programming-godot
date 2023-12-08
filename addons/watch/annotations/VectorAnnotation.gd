extends Annotation
class_name VectorAnnotation

static func name():
	return "Vector"

static func is_instance(annotation: Annotation) -> bool:
	return annotation is VectorAnnotation

static func can_display(value: Variant) -> bool:
	return value is Vector2

func _init(_line: int, _parent: Node):
	super(_line, _parent)
	display = VectorDisplay.new()
	display.set_size(get_line_height_square())
