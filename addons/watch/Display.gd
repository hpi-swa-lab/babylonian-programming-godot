extends Control
class_name Display

var annotation: Annotation

func _enter_tree():
	if size == Vector2.ZERO:
		set_anchors_and_offsets_preset(PRESET_FULL_RECT)

func update_value(value: Variant):
	pass

func get_annotation_offset() -> Vector2:
	return Vector2.ZERO

func get_watch_group() -> WatchGroup:
	return annotation.watch_group

func get_group():
	return get_watch_group().group
