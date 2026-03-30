class_name DisableTool
extends HaloTool

var _disabled_nodes: Array[Node2D]
var _disabled_icon: Texture2D


func _init() -> void:
	self.name = "Disable"
	self.color = Color.ORANGE
	self.icon = self.icon_from_atlas(4, 7)
	
	self._disabled_nodes = []
	self._disabled_icon = self.icon_from_atlas(7, 7)


func start_interaction() -> void:	
	var target = Halo.get_target()
	if target in self._disabled_nodes:
		self._enable_target(target)
	else:
		self._disable_target(target)


func _disable_target(target: Node2D) -> void:
	self._disabled_nodes.append(target)
	self._button.texture_normal = self._disabled_icon
	target.set_process(false)
	target.set_physics_process(false)
	target.self_modulate.a = 0.5
	self._set_collision_recursive(target, true)
	for child in target.get_children():
		if child is CanvasItem:
			child.self_modulate.a = 0.5
		if child is AnimationPlayer or child is AnimatedSprite2D:
			child.pause()


func _enable_target(target: Node2D) -> void:
	self._disabled_nodes.erase(target)
	self._button.texture_normal = self.icon
	target.set_process(true)
	target.set_physics_process(true)
	target.self_modulate.a = 1.0
	self._set_collision_recursive(target, false)
	for child in target.get_children():
		if child is CanvasItem:
			child.self_modulate.a = 1.0
		if child is AnimationPlayer or child is AnimatedSprite2D:
			child.play()


func _set_collision_recursive(node: Node, disabled: bool) -> void:
	for child in node.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", disabled)
		if child is Area2D:
			child.set_deferred("monitoring", not disabled)
			child.set_deferred("monitorable", not disabled)
		self._set_collision_recursive(child, disabled)


func get_button() -> TextureButton:
	var button = super.get_button()
	var target = Halo.get_target()
	button.texture_normal = self._disabled_icon if target in _disabled_nodes else icon
	return button
