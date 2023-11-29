extends Annotation
class_name FloatAnnotation

static func name():
	return "Float"

static func is_instance(annotation: Annotation) -> bool:
	return annotation is FloatAnnotation

static func can_display(value: Variant) -> bool:
	return value is float or value is int

func _init(_line: int, _text_edit: TextEdit):
	super(_line, _text_edit)
	var popup = PopupDisplay.new()
	display = popup
	var pausable = popup.set_inner(PausableDisplay.new())
	var tab_display = pausable.set_inner(TabDisplay.new())
	tab_display.set_size(Vector2(500, 5 * get_line_height()))
	tab_display.add_tab("Graph", FloatOverTimeDisplay.new())
	tab_display.add_tab("Current", TextDisplay.new())
