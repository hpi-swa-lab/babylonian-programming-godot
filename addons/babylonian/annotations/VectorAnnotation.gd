class_name VectorAnnotation extends Annotation

static func is_instance(annotation: Annotation) -> bool:
	return annotation is VectorAnnotation

static func can_display(value: Variant) -> bool:
	return value is Vector2

func create_display():
	popup_display.set_inner(VectorDisplay.new())
	popup_display.set_size(get_line_height_square())
