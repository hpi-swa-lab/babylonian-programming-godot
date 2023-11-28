extends Display
class_name ColorEditorDisplay

var color_override = null
var color_picker: ColorPicker

func _ready():
	color_picker = ColorPicker.new()
	color_picker.presets_visible = false
	color_picker.set_anchors_preset(PRESET_FULL_RECT)
	color_picker.color_changed.connect(self.color_changed)
	add_child(color_picker)

func update_value(new_value: Variant):
	if color_override != null:
		return
	color_picker.color = new_value

static func color_to_string(color: Color) -> String:
	return "Color.hex(0x" + color.to_html().substr(1) + ")"

func color_changed(color: Color):
	color_override = color
	annotation.replace_source(color_to_string(color))
