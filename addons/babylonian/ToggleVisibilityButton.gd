extends Button

@export var control: Control

func _ready():
	control.visibility_changed.connect(self.update_text)
	update_text()
	toggle_visibility()

func update_text():
	text = "Hide" if control.visible else "Show"

func _pressed():
	toggle_visibility()

func toggle_visibility():
	control.visible = not control.visible
