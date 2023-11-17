extends Control
class_name FloatOverTimeDisplay

var length: int = 2 * 60
var ring_buffer = PackedFloat64Array()
var start = 0
var end = 0

func _init():
	ring_buffer.resize(length + 1)

func inc(index: int) -> int:
	return (index + 1) % len(ring_buffer)

func append(value: float):
	if inc(end) == start:
		start = inc(start)
	ring_buffer[end] = value
	end = inc(end)

const MAX_FLOAT = 1.79769e308
const MIN_FLOAT = -1.79769e308

func buffer_size() -> int:
	var size = end - start
	if size < 0:
		size += len(ring_buffer)
	return size

func current_value() -> float:
	return ring_buffer[end if end != 0 else len(ring_buffer) - 1]

func get_min_max() -> Array:
	var min = MAX_FLOAT
	var max = MIN_FLOAT
	if start <= end:
		for index in range(start, end):
			var value = ring_buffer[index]
			min = minf(min, value)
			max = maxf(max, value)
	else:
		for index in range(start, len(ring_buffer)):
			var value = ring_buffer[index]
			min = minf(min, value)
			max = maxf(max, value)
		for index in range(0, end):
			var value = ring_buffer[index]
			min = minf(min, value)
			max = maxf(max, value)
	return [min, max]

func get_points(rect: Rect2, min: float, max: float) -> PackedVector2Array:
	var points = PackedVector2Array()
	points.resize(buffer_size())
	var point_index = 0
	if start <= end:
		for index in range(start, end):
			var value = ring_buffer[index]
			var x = float(point_index) / length * rect.size.x
			var y = remap(value, min, max, 0, rect.size.y)
			points[point_index] = Vector2(x, y)
			point_index += 1
	else:
		for index in range(start, len(ring_buffer)):
			var value = ring_buffer[index]
			var x = float(point_index) / length * rect.size.x
			var y = remap(value, min, max, 0, rect.size.y)
			points[point_index] = Vector2(x, y)
			point_index += 1
		for index in range(0, end):
			var value = ring_buffer[index]
			var x = float(point_index) / length * rect.size.x
			var y = remap(value, min, max, 0, rect.size.y)
			points[point_index] = Vector2(x, y)
			point_index += 1
	return points

func draw_float(position: Vector2, value: float, font_size: int):
	draw_string(
		get_theme_default_font(),
		position,
		str(value),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size)

func _draw():
	var rect = get_rect()
	#draw_rect(Rect2(Vector2.ZERO, rect.size), Color.BLACK)
	if buffer_size() < 2:
		return
	var min_max = get_min_max()
	var min = min_max[0]
	var max = min_max[1]
	var points = get_points(rect, min, max)
	draw_polyline(points, Color.WHITE)
	var font_size = 16
	draw_float(Vector2(rect.size.x, font_size), max, font_size)
	draw_float(Vector2(rect.size.x, rect.size.y), min, font_size)
	font_size *= 2
	draw_float(Vector2(rect.size.x, (rect.size.y + font_size) / 2), current_value(), font_size)
