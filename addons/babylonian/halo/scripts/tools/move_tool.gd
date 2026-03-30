class_name AxisMoveTool
extends HaloTool

var _target: Node2D = null

var target_start_pos: Vector2 = Vector2.ZERO
var drag_start_offset: Vector2 = Vector2.ZERO
var line: Line2D = null

func _init() -> void:
	self.name = "Move"
	self.description = "Drag to reposition (Shift to lock axis)"
	self.color = Color.ORANGE
	self.icon = icon_from_atlas(6, 3)
	
func get_button() -> TextureButton:
	var button = super.get_button()
	return button

func start_interaction() -> void:
	self._target = Halo.get_target()
	self._button.modulate = Color.DARK_RED
	self.target_start_pos = self._target.global_position
	self.drag_start_offset = Halo.get_global_mouse_position() - self.target_start_pos
	self.line = Line2D.new()
	self.line.width = 1
	self.line.default_color = Color.DARK_RED
	self.line.points = [Vector2.ZERO, Vector2.ZERO]
	self.line.visible = false
	self._target.add_child(self.line)

func finish_interaction() -> void:
	Halo.persistence.set_property(self._target, "global_position", self.target_start_pos)

	self._button.modulate = Color.ORANGE
	
	self._target.remove_child(self.line)
	self.line.queue_free()
	self.line = null
	
	self._target = null

func interact(delta: float) -> void:
	var mouse_pos := Halo.get_global_mouse_position() - self.drag_start_offset
	var delta_pos := mouse_pos - target_start_pos

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if Input.is_key_pressed(KEY_SHIFT):
			self.line.visible = true
			var locked_axis = Vector2(1, 0) if abs(delta_pos.x) > abs(delta_pos.y) else Vector2(0, 1)
			if locked_axis.x != 0:
				self._button.texture_normal = icon_from_atlas(3, 8)
				self._target.global_position = Vector2(mouse_pos.x, target_start_pos.y)
			else:
				self._button.texture_normal = icon_from_atlas(3, 7)
				self._target.global_position = Vector2(target_start_pos.x, mouse_pos.y)
			
			var local_start := self._target.to_local(target_start_pos)
			var local_mouse := self._target.to_local(mouse_pos)
			if locked_axis == Vector2.ZERO:
				self.line.points = [local_start, local_mouse]
			elif locked_axis.x != 0:
				self.line.points = [local_start, Vector2(local_mouse.x, local_start.y)]
			else:
				self.line.points = [local_start, Vector2(local_start.x, local_mouse.y)]
		else:
			self._button.texture_normal = icon_from_atlas(6, 3)
			self._target.global_position = mouse_pos
			self.line.visible = false
	else:
		Halo.finish_previous_tool_interaction()
