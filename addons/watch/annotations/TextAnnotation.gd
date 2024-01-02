extends Annotation
class_name TextAnnotation

static func name():
	return "Text"
	
static func is_instance(annotation: Annotation) -> bool:
	return annotation is TextAnnotation

static func can_display(value: Variant) -> bool:
	return true

func _init(_line: int, _parent: Node):
	super(_line, _parent)
	var popup = PopupDisplay.new()
	display = popup
	var text = popup.set_inner(TextDisplay.new())
	popup.set_size(Vector2(200, get_line_height()))

func get_offset():
	return Vector2(0, -get_line_height() * 0.15)
