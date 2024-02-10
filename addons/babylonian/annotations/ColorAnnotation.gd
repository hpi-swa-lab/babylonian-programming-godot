class_name ColorAnnotation extends Annotation

static func is_instance(annotation: Annotation) -> bool:
	return annotation is ColorAnnotation

static func can_display(value: Variant) -> bool:
	return value is Color

func create_display():
	var color_display =            \
		ColorEditorDisplay.new()   \
		if Engine.is_editor_hint() \
		else ColorDisplay.new()
	popup_display.set_inner(color_display)
	popup_display.set_size(get_line_height_square())
