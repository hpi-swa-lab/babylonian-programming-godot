class_name Annotation

const ANNOTATION_OFFSET = Vector2(40, 0)

var line = 0
var text_edit: TextEdit
var node: Control
var last_scroll_pos
var last_column

static func is_instance(annotation: Annotation) -> bool:
	return false

static func can_display(value: Variant) -> bool:
	return false
	
func copy_settings_from(other: Annotation):
	line = other.line
	text_edit = other.text_edit

func is_valid():
	return is_watch_valid()

func is_watch_valid() -> bool:
	return text_edit.get_line(line).contains("watch(")

func create():
	pass

func get_line_height():
	return text_edit.get_line_height() - text_edit.get_theme_constant("line_spacing")

func get_line_height_square():
	var line_height = get_line_height()
	return Vector2(line_height, line_height)

func update():
	var column = len(text_edit.get_line(line))
	if text_edit.scroll_vertical == last_scroll_pos and last_column == column:
		return
	last_scroll_pos = text_edit.scroll_vertical
	last_column = column
	var rect = text_edit.get_rect_at_line_column(line, column)
	if rect.position.y >= 0:
		node.show()
		node.set_position(Vector2(rect.end.x, rect.position.y) + ANNOTATION_OFFSET)
	else:
		node.hide()

func update_value(value: Variant):
	pass
