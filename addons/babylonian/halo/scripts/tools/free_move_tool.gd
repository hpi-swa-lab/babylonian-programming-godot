class_name FreeMoveTool extends HaloTool

func _init():
	name = "Free Move"
	color = Color.DODGER_BLUE
	icon = icon_from_atlas(6, 3)

func activate() -> void:
	pass

func deactivate() -> void:
	pass

func process(delta: float) -> void:
	if Input.is_action_just_pressed("left_mouse_button"):
		self.target.global_position = Halo.get_global_mouse_position()
