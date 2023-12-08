extends Annotation
class_name ColorAnnotation

static func name():
	return "Color"
	
static func is_instance(annotation: Annotation) -> bool:
	return annotation is ColorAnnotation

static func can_display(value: Variant) -> bool:
	return value is Color

func _init(_line: int, _parent: Node):
	super(_line, _parent)
	var color_editor = ColorEditorDisplay.new()
	display = color_editor
	color_editor.set_size(get_line_height_square())
