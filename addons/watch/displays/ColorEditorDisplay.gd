extends Display
class_name ColorEditorDisplay

var color_override = null
var color_picker_button: ColorPickerButton

func _init():
	color_picker_button = ColorPickerButton.new()
	var color_picker = color_picker_button.get_picker()
	color_picker.presets_visible = false
	color_picker_button.color_changed.connect(self.color_changed)
	color_picker_button.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	add_child(color_picker_button)

func update_value(new_value: Variant):
	if color_override != null:
		return
	color_picker_button.color = new_value

static func color_to_string(color: Color) -> String:
	return "Color.hex(0x" + color.to_html().substr(1) + ")"

func color_changed(color: Color):
	color_override = color
	annotation.replace_source(color_to_string(color))
