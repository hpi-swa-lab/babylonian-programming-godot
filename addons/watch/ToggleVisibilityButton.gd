extends Button

@export var control: Control

func _ready():
	control.visibility_changed.connect(self.update_text)
	update_text()

func update_text():
	text = "Hide" if control.visible else "Show"

func _pressed():
	control.visible = not control.visible
