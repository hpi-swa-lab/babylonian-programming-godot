class_name Annotation

const ANNOTATION_OFFSET = Vector2(40, 0)

var line = 0
var text_edit: TextEdit
var display: Display : set = set_display
var last_scroll_pos
var last_column

var watch_regex = RegEx.create_from_string("(B\\.watch\\()(.*)(\\))")

static func is_instance(annotation: Annotation) -> bool:
	return false

static func can_display(value: Variant) -> bool:
	return false

func _init(_line: int, _text_edit: TextEdit):
	line = _line
	text_edit = _text_edit

static func from(other: Annotation, new_class: RefCounted):
	return new_class.new(other.line, other.text_edit)

func set_display(new_display: Display):
	display = new_display
	new_display.annotation = self

func is_valid():
	return is_watch_valid()

func is_watch_valid() -> bool:
	return watch_regex.search(get_line()) != null

func get_line_height():
	return text_edit.get_line_height() - text_edit.get_theme_constant("line_spacing")

func get_line_height_square():
	var line_height = get_line_height()
	return Vector2(line_height, line_height)

func get_offset():
	return Vector2.ZERO

func get_line() -> String:
	return text_edit.get_line(line)

func set_line(new_line: String):
	text_edit.set_line(line, new_line)

func update_text_edit_line_drawing_cache():
	# A TextEdit needs to have an up-to-date line_drawing_cache
	# to properly answer get_rect_at_line_column requests.
	text_edit.queue_redraw()

func replace_source(new_source: String):
	set_line(watch_regex.sub(get_line(), "$1" + new_source.replace("$", "$$") + "$3"))
	update_text_edit_line_drawing_cache()

func update():
	var column = len(get_line())
	if text_edit.scroll_vertical == last_scroll_pos and last_column == column:
		return
	last_scroll_pos = text_edit.scroll_vertical
	last_column = column
	var rect = text_edit.get_rect_at_line_column(line, column)
	if rect.position.y >= 0:
		display.show()
		display.set_position((
			Vector2(rect.end.x, rect.position.y) +
			get_offset() +
			display.get_annotation_offset() +
			ANNOTATION_OFFSET))
	else:
		display.hide()

func update_value(value: Variant):
	display.update_value(value)
