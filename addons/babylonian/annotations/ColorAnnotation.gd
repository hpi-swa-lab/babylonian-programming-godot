class_name ColorAnnotation extends Annotation

static func is_instance(annotation: Annotation) -> bool:
	return annotation is ColorAnnotation

static func can_display(value: Variant) -> bool:
	return value is Color

func create_display():
	var popup = PopupDisplay.new()
	display = popup
	var color_editor = popup.set_inner(ColorEditorDisplay.new())
	popup.set_size(get_line_height_square())
