extends Display
class_name PopupDisplay

var popup: Window
var inner_display: Display

func _init():
	popup = Window.new()
	popup.exclusive = false
	add_child(popup)

func _ready():
	popup.popup(get_rect())

func set_inner(display: Display):
	inner_display = display
	popup.add_child(inner_display)

func update_value(new_value: Variant):
	inner_display.update_value(new_value)
