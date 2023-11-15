extends Annotation
class_name ColorAnnotation

static func name():
	return "Color"
	
static func is_instance(annotation: Annotation) -> bool:
	return annotation is ColorAnnotation

static func can_display(value: Variant) -> bool:
	return value is Color

func create():
	node = ColorRect.new()
	node.set_size(get_line_height_square())

func update_value(value: Variant):
	node.color = value
