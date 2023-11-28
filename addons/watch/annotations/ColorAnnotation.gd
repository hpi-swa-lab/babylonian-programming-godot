extends Annotation
class_name ColorAnnotation

static func name():
	return "Color"
	
static func is_instance(annotation: Annotation) -> bool:
	return annotation is ColorAnnotation

static func can_display(value: Variant) -> bool:
	return value is Color

func _init(_line: int, _text_edit: TextEdit):
	super(_line, _text_edit)
	var popup = PopupDisplay.new()
	display = popup
	var color_editor = popup.set_inner(ColorEditorDisplay.new())
	color_editor.set_size(get_line_height_square())
