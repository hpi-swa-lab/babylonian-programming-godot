class_name FloatAnnotation extends Annotation

static func is_instance(annotation: Annotation) -> bool:
	return annotation is FloatAnnotation

static func can_display(value: Variant) -> bool:
	return value is float or value is int

func create_display():
	var popup = PopupDisplay.new()
	display = popup
	var pausable = popup.set_inner(PausableDisplay.new())
	var tab = pausable.set_inner(TabDisplay.new())
	tab.add_tab("Graph", FloatOverTimeDisplay.new())
	tab.add_tab("Current", TextDisplay.new())
	popup.set_size(Vector2(500, 5 * get_line_height()))
