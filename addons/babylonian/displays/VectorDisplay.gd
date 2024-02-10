extends Display
class_name VectorDisplay

var value: Vector2

func _draw():
	var rect = get_rect()
	var start = rect.size / 2
	var length = min(rect.size.x, rect.size.y) 
	var pointer = value.normalized() * length
	var end = start + pointer
	var right_tip = end + pointer.rotated(PI * 3 / 4) / 3
	var left_tip = end + pointer.rotated(-PI * 3 / 4) / 3
	draw_line(start, end, Color.WHITE, 2.0, true)
	draw_line(end, right_tip, Color.WHITE, 2.0, true)
	draw_line(end, left_tip, Color.WHITE, 2.0, true)

func update_value(new_value: Variant):
	value = new_value
	queue_redraw()
