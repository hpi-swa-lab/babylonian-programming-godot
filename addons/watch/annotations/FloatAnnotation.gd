extends Annotation
class_name FloatAnnotation

static func name():
	return "Float"

static func is_instance(annotation: Annotation) -> bool:
	return annotation is FloatAnnotation

static func can_display(value: Variant) -> bool:
	return value is float or value is int

func _init(_line: int, _parent: Node):
	super(_line, _parent)
	var popup = PopupDisplay.new()
	display = popup
	var pausable = popup.set_inner(PausableDisplay.new())
	var tab = pausable.set_inner(TabDisplay.new())
	tab.add_tab("Graph", FloatOverTimeDisplay.new())
	tab.add_tab("Current", TextDisplay.new())
	popup.set_size(Vector2(500, 5 * get_line_height()))
