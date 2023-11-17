extends Display
class_name TextDisplay

var label: Label

func _ready():
	label = Label.new()
	label.text_direction = Control.TEXT_DIRECTION_LTR
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.add_theme_font_size_override("font_size", size.y)
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color.TRANSPARENT
	label.add_theme_stylebox_override("normal", style_box)
	add_child(label)

func update_value(new_value: Variant):
	label.text = str(new_value)
