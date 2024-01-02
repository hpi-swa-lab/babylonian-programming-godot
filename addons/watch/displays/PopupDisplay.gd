extends Display
class_name PopupDisplay

var inner_display: Display
var offset = Vector2.ZERO

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		handle_mouse_motion(event)

func handle_mouse_motion(event: InputEventMouseMotion):
	var rect = Rect2(get_screen_position(), get_global_rect().size)
	if not rect.has_point(event.global_position - event.relative):
		return
	if event.button_mask & MOUSE_BUTTON_LEFT:
		position += event.relative
		offset += event.relative
		queue_redraw()
	if event.button_mask & MOUSE_BUTTON_RIGHT:
		size += event.relative

func get_annotation_offset() -> Vector2:
	return offset

func set_inner(display: Display):
	inner_display = display
	add_child(inner_display)
	inner_display.annotation = annotation
	return display

func update_value(new_value: Variant):
	inner_display.update_value(new_value)

func _draw():
	var half_line_height = Vector2(0, annotation.get_line_height() / 2)
	draw_line(half_line_height, half_line_height - offset, Color.WHITE)
