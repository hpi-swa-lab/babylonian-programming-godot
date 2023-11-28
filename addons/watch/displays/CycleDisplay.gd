extends Display
class_name CycleDisplay

var index = 0
var displays: Array[Display]

func _init():
	var button = Button.new()
	button.text = "↔"
	button.pressed.connect(self.toggle)
	add_child(button)

func toggle():
	if len(displays) == 0:
		return
	remove_child(displays[index])
	index += 1
	index %= len(displays)
	add_child(displays[index])

func add_display(display: Display):
	if len(displays) == 0:
		add_child(display)
	displays.append(display)
	display.annotation = annotation
	return display

func update_value(new_value: Variant):
	for display in displays:
		display.update_value(new_value)
