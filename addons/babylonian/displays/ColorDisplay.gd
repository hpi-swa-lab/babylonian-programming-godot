extends Display
class_name ColorDisplay

var color_rect: ColorRect

func _init():
	color_rect = ColorRect.new()
	color_rect.set_anchors_preset(PRESET_FULL_RECT)
	add_child(color_rect)

func update_value(new_value: Variant):
	color_rect.color = new_value
