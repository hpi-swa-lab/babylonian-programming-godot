class_name HaloUIBuilder
extends RefCounted

var _halo_ui: Node2D
var _label: Label


func _init() -> void:
	self._halo_ui = Node2D.new()
	self._halo_ui.name = "HaloUI"
	
	self._label = self._build_label()
	self._halo_ui.add_child(self._label)


func get_halo_ui(target: Node2D, tools: Array[HaloTool]) -> Node2D:
	# update text and tools if needed, but reuse node and buttons
	self._label.text = target.name
	self._label.reset_size()
	self._label.position = Vector2(-_label.size.x / 2.0, 24)

	# get buttons from tools with matching filter_type
	var buttons: Array[TextureButton] = []
	for tool in tools:
		var button = tool.get_button()
		if tool.filter_type == null or is_instance_of(target, tool.filter_type):
			buttons.append(button)
			self._halo_ui.add_child(button)
		else:
			self._halo_ui.remove_child(button)

	# scale the entire UI based on target's actual visual size
	var ui_scale = self._compute_ui_scale(target)
	self._halo_ui.scale = Vector2(ui_scale, ui_scale)
	self._position_buttons(buttons)

	return self._halo_ui


func _position_buttons(buttons: Array) -> void:
	# arrange buttons in circle
	var radius = 16.0
	var angle_step = TAU / buttons.size()
	var angle = -PI / 2.0  # start at the top (-90°)

	for button in buttons:
		var pos = Vector2(cos(angle), sin(angle)) * radius
		button.position = pos - (button.size * button.scale) / 2.0
		angle += angle_step


func _build_label():
	_label = Label.new()
	_label.position = Vector2(0, 25)  # default, will be updated per target
	_label.z_index = 128
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_label.add_theme_font_override("font", load("res://addons/babylonian/halo/assets/PixelOperator8.ttf"))
	_label.add_theme_font_size_override("font_size", 8)
	_label.add_theme_constant_override("shadow_offset_x", 1)
	_label.add_theme_constant_override("shadow_offset_y", 1)
	_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	return _label


func style_static_saving_mode_checkbox(checkbox: CheckBox, position: Vector2 = Vector2(5, 5)) -> CanvasLayer:
	var canvas = CanvasLayer.new()
	canvas.layer = 100

	var panel = PanelContainer.new()
	panel.position = position
	panel.custom_minimum_size = Vector2(200, 50)

	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.2, 0.2, 0.25, 0.9)
	style_box.set_border_width_all(2)
	style_box.set_corner_radius_all(8)
	style_box.border_color = Color(0.4, 0.4, 0.5, 1.0)
	panel.add_theme_stylebox_override("panel", style_box)
	canvas.add_child(panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel.add_child(margin)

	checkbox.text = "Save Changes?"
	checkbox.focus_mode = Control.FOCUS_NONE
	checkbox.position = Vector2.ZERO
	margin.add_child(checkbox)

	var _on_checkbox_toggled = func _update_checkbox_color(is_checked: bool) -> void:
		if is_checked:
			checkbox.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
			checkbox.add_theme_color_override("font_hover_color", Color(0.5, 1.0, 0.5))
			checkbox.add_theme_color_override("font_pressed_color", Color(0.4, 1.0, 0.4))
			checkbox.add_theme_color_override("font_focus_color", Color(0.4, 1.0, 0.4))
			checkbox.text = "Saving changes"
		else:
			checkbox.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
			checkbox.add_theme_color_override("font_hover_color", Color(1.0, 0.5, 0.5))
			checkbox.add_theme_color_override("font_pressed_color", Color(1.0, 0.4, 0.4))
			checkbox.add_theme_color_override("font_focus_color", Color(1.0, 0.4, 0.4))
			checkbox.text = "Playground mode"
			
	checkbox.toggled.connect(_on_checkbox_toggled)
	
	return canvas


func _compute_ui_scale(target: Node2D) -> float:
	var extent = self._get_visual_extent(target)
	if extent <= 0.0:
		return 1.0
	var scale_factor = extent / 16.0
	return clampf(scale_factor, 0.8, 6.0)


func _get_visual_extent(target: Node2D) -> float:
	var best = 0.0
	var global_scale = target.global_scale.abs()

	# target size
	var target_size = self._get_bounding_box(target).size
	if target_size != Vector2.ZERO:
		var world_half = target_size * global_scale * 0.5
		best = maxf(world_half.x, world_half.y)

	# get max from children
	for child in target.get_children():
		if not child is Node2D:
			continue
		var child_size = self._get_bounding_box(child).size
		if child_size == Vector2.ZERO:
			continue
		var child_scale = (child as Node2D).scale.abs()
		# account for child's scale
		var world_half = child_size * child_scale * global_scale * 0.5
		var extent = maxf(world_half.x, world_half.y)
		best = maxf(best, extent)

	return best


func _get_bounding_box(node: Node) -> Rect2:
	if node is Sprite2D:
		return node.get_rect()
	if node is AnimatedSprite2D:
		var frames = node.sprite_frames
		if frames and frames.has_animation(node.animation):
			var tex = frames.get_frame_texture(node.animation, node.frame)
			if tex:
				var s = tex.get_size()
				return Rect2(-s / 2.0, s) if node.centered else Rect2(Vector2.ZERO, s)
	if node is CollisionShape2D and node.shape:
		return node.shape.get_rect()
	return Rect2()
