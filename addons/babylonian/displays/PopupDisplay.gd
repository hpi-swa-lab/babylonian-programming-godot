class_name PopupDisplay extends Display

var inner_display: Display
var offset = Vector2.ZERO

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		handle_mouse_motion(event)

func handle_mouse_motion(event: InputEventMouseMotion):
	if not get_global_rect().has_point(event.position - event.relative):
		return
	get_viewport().set_input_as_handled()
	if event.button_mask & MOUSE_BUTTON_LEFT:
		position += event.relative
		offset += event.relative
		queue_redraw()
	if event.button_mask & MOUSE_BUTTON_RIGHT:
		size += event.relative

func get_annotation_offset() -> Vector2:
	return offset + get_group_offset()

func get_group_offset() -> Vector2:
	var group = get_group()
	if is_instance_valid(group) and group is Node2D:
		return get_node_2d_group_offset(group)
	return Vector2.ZERO

var NODE_OFFSET = Vector2.UP * 50

func get_node_2d_group_offset(node: Node2D):
	var anchor = node.position
	return node.get_viewport_transform() * anchor + NODE_OFFSET

func set_inner(display: Display):
	inner_display = display
	add_child(inner_display)
	inner_display.annotation = annotation
	return display

func update_value(new_value: Variant):
	inner_display.update_value(new_value)

func draw_origin_connection():
	var group = get_group()
	return Engine.is_editor_hint() or is_instance_valid(group) and group is Node2D

func _draw():
	if not draw_origin_connection():
		return
	var half_line_height = Vector2(0, annotation.get_line_height() / 2)
	draw_line(half_line_height, half_line_height - offset, Color.WHITE)
	# for debugging
	#draw_rect(Rect2(Vector2.ZERO, size), Color.RED)
