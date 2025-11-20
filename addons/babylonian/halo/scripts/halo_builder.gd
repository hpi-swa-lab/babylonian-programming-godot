class_name HaloBuilder
extends Node

var _tools: Array[HaloTool] = []


func _ready() -> void:
	_register_tools()


func _register_tools() -> void:
	# Register all available tools
	_tools.append(FreeMoveTool.new())
	# Add more tools as needed


func build_halo(target: CanvasItem) -> Node2D:
	var halo_ui = Node2D.new()
	halo_ui.name = "HaloUI"
	
	# Draw outline visual
	_create_outline(halo_ui, target)
	
	# Create buttons
	var buttons = []
	for tool in _tools:
		var button = _create_button(tool, target)
		buttons.append(button)
		halo_ui.add_child(button)
	
	# Position buttons in circle
	_position_buttons(buttons, target)
	
	# Store button references for recycling
	halo_ui.set_meta("buttons", buttons)
	
	return halo_ui


func update_buttons(halo_ui: Node2D) -> void:
	var buttons = halo_ui.get_meta("buttons", [])
	var target = halo_ui.get_parent()
	
	# Update button count if tools changed
	while buttons.size() < _tools.size():
		var tool = _tools[buttons.size()]
		var button = _create_button(tool, target)
		buttons.append(button)
		halo_ui.add_child(button)
	
	while buttons.size() > _tools.size():
		var button = buttons.pop_back()
		button.queue_free()
	
	# Update existing buttons
	for i in range(_tools.size()):
		_update_button(buttons[i], _tools[i], target)
	
	halo_ui.set_meta("buttons", buttons)
	_position_buttons(buttons, target)


func add_tool(tool: HaloTool) -> void:
	_tools.append(tool)


func _create_button(tool: HaloTool, target: CanvasItem) -> TextureButton:
	var button = TextureButton.new()
	button.texture_normal = tool.icon
	button.custom_minimum_size = Vector2(64, 64)
	button.modulate = tool.color
	button.pressed.connect(_on_tool_clicked.bind(tool, target))
	
	return button


func _update_button(button: TextureButton, tool: HaloTool, target: CanvasItem) -> void:
	# Disconnect old signals
	for connection in button.pressed.get_connections():
		button.pressed.disconnect(connection["callable"])
	
	# Update button properties
	button.texture_normal = tool.icon
	button.modulate = tool.color
	button.pressed.connect(_on_tool_clicked.bind(tool, target))


func _create_outline(halo_ui: Node2D, target: CanvasItem) -> void:
	# Simple outline - can be enhanced with custom drawing
	var outline = ColorRect.new()
	outline.color = Color(1, 1, 0, 0.3)
	outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if target is Control:
		var ctrl = target as Control
		outline.size = ctrl.size
		outline.position = -ctrl.size / 2
	else:
		outline.size = Vector2(100, 100)
		outline.position = -Vector2(50, 50)
	
	halo_ui.add_child(outline)


func _position_buttons(buttons: Array, target: CanvasItem) -> void:
	var radius = 150.0
	var angle_step = TAU / buttons.size() if buttons.size() > 0 else 0
	
	for i in range(buttons.size()):
		var angle = i * angle_step
		var pos = Vector2(cos(angle), sin(angle)) * radius
		buttons[i].position = pos - buttons[i].size / 2


func _on_tool_clicked(tool: HaloTool, target: CanvasItem) -> void:
	tool.on_click(target)
