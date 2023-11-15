extends Annotation
class_name TextAnnotation

static func name():
	return "Text"
	
static func is_instance(annotation: Annotation) -> bool:
	return annotation is TextAnnotation

static func can_display(value: Variant) -> bool:
	return true

func create():
	node = RichTextLabel.new()
	node.fit_content = true
	node.text_direction = Control.TEXT_DIRECTION_LTR
	node.autowrap_mode = TextServer.AUTOWRAP_OFF
	node.add_theme_font_size_override("normal_font_size", get_line_height())
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color.TRANSPARENT
	node.add_theme_stylebox_override("normal", style_box)

func get_offset():
	return Vector2(0, -get_line_height() * 0.15)

func update_value(value: Variant):
	node.text = str(value)
