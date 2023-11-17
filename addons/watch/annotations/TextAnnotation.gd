extends Annotation
class_name TextAnnotation

static func name():
	return "Text"
	
static func is_instance(annotation: Annotation) -> bool:
	return annotation is TextAnnotation

static func can_display(value: Variant) -> bool:
	return true

func _init(_line: int, _text_edit: TextEdit):
	super(_line, _text_edit)
	display = TextDisplay.new()
	display.set_size(Vector2(200, get_line_height()))

func get_offset():
	return Vector2(0, -get_line_height() * 0.15)
