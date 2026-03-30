class_name RotateTool
extends HaloTool

var _target: Node2D = null
var start_angle: float = 0.0
var start_offset: float = 0.0
const threshold: float = 0.2 

func _init() -> void:
	self.name = "Rotate"
	self.description = "Drag to rotate (Shift to snap to 90°)"
	self.color = Color.ORANGE
	self.icon = icon_from_atlas(4, 1)


func calculate_angle() -> float:
	var pos = Halo.get_global_mouse_position() - self._target.global_position
	return atan2(-pos.y, pos.x)


func start_interaction() -> void:
	self._target = Halo.get_target()
	self._button.modulate = Color.DARK_RED
	self.start_angle = self._target.rotation
	self.start_offset = calculate_angle()


func finish_interaction() -> void:
	Halo.persistence.set_property(self._target, "rotation", self.start_angle)
	self._button.modulate = Color.ORANGE
	self._target = null


func interact(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var angle_delta = self.calculate_angle()
		var angle = self.start_offset + self.start_angle - angle_delta
		
		if Input.is_key_pressed(KEY_SHIFT):
			angle = fmod(angle, 2 * PI)
			if angle < 0.0:
				angle += 2 * PI
			for cardinal in [0.0, PI/2, PI, 3*PI/2, 2*PI]:
				if abs(angle - cardinal) <= threshold:
					angle = fmod(cardinal, 360)
		self._target.rotation = angle
	else:
		Halo.finish_previous_tool_interaction()
