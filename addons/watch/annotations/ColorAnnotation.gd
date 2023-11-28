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
	var cycle = popup.set_inner(CycleDisplay.new())
	var color = cycle.add_display(ColorDisplay.new())
	color.set_size(get_line_height_square())
	var color_editor = cycle.add_display(ColorEditorDisplay.new())
	color_editor.set_size(get_line_height_square())
