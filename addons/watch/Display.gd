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
