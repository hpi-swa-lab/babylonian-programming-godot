class_name Halo 
extends Node2D

# 0 = no modifier, 1 = SHIFT pressed
var current_modifier_index: int = 0
var tool_slots: Array[Array] = []

# visual elements
var _buttons: Array[TextureButton] = []
var _target: CanvasItem = null
var _target_is_root: bool = false
var _selection_rect: ColorRect = null
var _name_tag: Label = null
var _position_tag: Label = null

const RADIUS_BASE: float = 16.0
var _radius: float = RADIUS_BASE
var _is_static: bool = false

func _ready() -> void:
	_setup_ui_elements()
	_setup_tools()

func _setup_ui_elements() -> void:
	# Selection rect
	_selection_rect = ColorRect.new()
	_selection_rect.color = Color(1, 1, 1, 0.1)
	_selection_rect.z_index = 110
	_selection_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_selection_rect)
	
	# Info tags
	_name_tag = Label.new()
	_name_tag.z_index = 130
	add_child(_name_tag)
	
	_position_tag = Label.new()
	_position_tag.z_index = 130
	add_child(_position_tag)
	
func _setup_tools() -> void:
	self.tool_slots = [
		[FreeMoveTool.new()]
	]

func set_target(target: CanvasItem, is_root: bool = false) -> void:
	# cleanup old tools
	if _target:
		for slot in tool_slots:
			for tool in slot:
				tool.cleanup()
	
	_target = target
	_target_is_root = is_root
	
	if target:
		_name_tag.text = target.name
		_update_position_tag()
		target.item_rect_changed.connect(_reposition)
		_reposition()
		_rebuild_buttons()
	else:
		_clear_buttons()
		_selection_rect.visible = false

func _rebuild_buttons() -> void:
	_clear_buttons()
	
	var active_tools = _get_active_tools()
	var total_buttons = active_tools.size()
	
	_radius = RADIUS_BASE * (sin(PI / 8) / sin(PI / total_buttons))
	
	# Create tool buttons
	for i in active_tools.size():
		var tool = active_tools[i]
		var button = _create_tool_button(tool, i, total_buttons)
		_buttons.append(button)
		add_child(button)
	
	_position_tags()

func _create_tool_button(tool: Tool, index: int, total: int) -> TextureButton:
	var button = TextureButton.new()
	button.texture_normal = tool.icon
	button.modulate = tool.color
	button.size = Vector2(50, 50)
	button.scale = Vector2(0.2, 0.2)
	button.z_index = 128
	
	# Add glow for active tools
	if tool.is_active:
		button.modulate = tool.color.lightened(0.4)
	
	button.pressed.connect(func(): _on_tool_clicked(tool))
	
	_position_button(button, index, total)
	return button

func _position_button(button: TextureButton, index: int, total: int) -> void:
	var angle: float = index * 2 * PI / total
	button.position = Vector2(
		cos(angle) * _radius,
		sin(angle) * _radius
	) - (button.size * button.scale) / 2

func _position_tags() -> void:
	var name_size = _name_tag.get_theme_default_font().get_string_size(
		_name_tag.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 
		_name_tag.get_theme_default_font_size()
	)
	_name_tag.position = Vector2(-name_size.x / 2, -_radius - 20)
	_position_tag.position = Vector2(_radius + 10, 0)

func _clear_buttons() -> void:
	for button in _buttons:
		button.queue_free()
	_buttons.clear()

func _get_active_tools() -> Array[Tool]:
	var active: Array[Tool] = []
	for slot in tool_slots:
		var index = min(current_modifier_index, slot.size() - 1)
		active.append(slot[index])
	return active

func _on_tool_clicked(tool: Tool) -> void:
	if not _target:
		return
	tool.on_click(_target)
	_rebuild_buttons()  # Refresh to show active state

func _reposition() -> void:
	if _target and not _is_static:
		global_position = _target.global_position
	_update_selection_rect()
	_update_position_tag()

func _update_selection_rect() -> void:
	if not _target:
		_selection_rect.visible = false
		return
		
	var rect := Rect2()
	
	if _target is Control:
		rect = _target.get_global_rect()
	elif _target is Sprite2D:
		var sprite = _target as Sprite2D
		if sprite.texture:
			rect = Rect2(_target.global_position - sprite.texture.get_size() / 2, sprite.texture.get_size())
	elif _target is CollisionShape2D:
		var collision = _target as CollisionShape2D
		if collision.shape:
			var shape_rect = collision.shape.get_rect()
			rect = Rect2(_target.global_position - shape_rect.size / 2, shape_rect.size)
	
	if rect.size.length() > 0:
		_selection_rect.global_position = rect.position
		_selection_rect.size = rect.size
		_selection_rect.visible = true
	else:
		_selection_rect.visible = false

func _update_position_tag() -> void:
	if _target:
		var pos = _target.global_position
		_position_tag.text = "(%s, %s)" % [
			str(pos.x).pad_decimals(1),
			str(pos.y).pad_decimals(1)
		]

func _input(event: InputEvent) -> void:
	# Handle SHIFT for wheel switching
	if event is InputEventKey:
		var key_event = event as InputEventKey
		if key_event.keycode == KEY_SHIFT:
			if key_event.pressed and current_modifier_index == 0:
				current_modifier_index = 1
				_rebuild_buttons()
			elif not key_event.pressed and current_modifier_index == 1:
				current_modifier_index = 0
				_rebuild_buttons()

func _process(delta: float) -> void:
	if not _target:
		return
		
	_reposition()
	
	# Process active tools
	var active_tools = _get_active_tools()
	for tool in active_tools:
		if tool.is_active:
			tool.process(delta)
