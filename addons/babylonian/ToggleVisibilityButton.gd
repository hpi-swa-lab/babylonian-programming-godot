extends Button

@export var control: Control

func _ready():
	self._pressed()


func _pressed():
	control.visible = not control.visible
	text = "Hide" if control.visible else "Show"
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE if control.visible else Control.MOUSE_FILTER_PASS
