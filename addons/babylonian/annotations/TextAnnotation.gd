class_name TextAnnotation extends Annotation

static func is_instance(annotation: Annotation) -> bool:
	return annotation is TextAnnotation

static func can_display(value: Variant) -> bool:
	return true

func create_display():
	popup_display.set_inner(TextDisplay.new())
	popup_display.set_size(Vector2(200, get_line_height()))

func get_offset():
	return Vector2(0, -get_line_height() * 0.15)
