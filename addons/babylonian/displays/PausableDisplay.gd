extends Display
class_name PausableDisplay

var is_paused = false
var inner: Display
var button: Button

func _init():
	button = Button.new()
	update_button_text()
	button.pressed.connect(self.toggle)
	button.focus_mode = Control.FOCUS_NONE
	add_child(button)

func _ready():
	button.set_anchor_and_offset(SIDE_LEFT, 0, -button.size.x)

func toggle():
	is_paused = not is_paused
	update_button_text()

func update_button_text():
	button.text = "▶" if is_paused else "⏸"

func set_inner(display: Display):
	inner = display
	inner.annotation = annotation
	add_child(inner)
	return inner

func update_value(new_value: Variant):
	if is_paused:
		return
	inner.update_value(new_value)
