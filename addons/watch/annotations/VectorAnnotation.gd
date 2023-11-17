extends Annotation
class_name VectorAnnotation

static func name():
	return "Vector"

static func is_instance(annotation: Annotation) -> bool:
	return annotation is VectorAnnotation

static func can_display(value: Variant) -> bool:
	return value is Vector2

func _init(_line: int, _text_edit: TextEdit):
	super(_line, _text_edit)
	node = VectorDisplay.new()
	node.set_size(get_line_height_square())

func update_value(value: Variant):
	node.update_value(value)
