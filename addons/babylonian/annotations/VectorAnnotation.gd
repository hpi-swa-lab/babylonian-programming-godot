extends Annotation
class_name VectorAnnotation

static func name():
	return "Vector"

static func is_instance(annotation: Annotation) -> bool:
	return annotation is VectorAnnotation

static func can_display(value: Variant) -> bool:
	return value is Vector2

func create_display():
	var popup = PopupDisplay.new()
	display = popup
	var vector = popup.set_inner(VectorDisplay.new())
	popup.set_size(get_line_height_square())
