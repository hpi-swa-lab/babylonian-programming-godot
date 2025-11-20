extends Node2D

var _current_target: CanvasItem = null
var _is_root: bool = false
var _shift_pressed: bool = false
var _ctrl_pressed: bool = false

var _halo_manager: HaloManager


func _ready() -> void:
	set_process_input(true)
	_halo_manager = HaloManager.new()
	add_child(_halo_manager)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var shift = event.shift_pressed
		var ctrl = event.ctrl_pressed
		
		if shift != _shift_pressed or ctrl != _ctrl_pressed:
			_shift_pressed = shift
			_ctrl_pressed = ctrl
			_halo_manager.update_tool_palette()


func set_target(target: CanvasItem, is_root: bool = false) -> void:
	if _current_target != null:
		if _current_target.tree_exiting.is_connected(_on_target_tree_exiting):
			_current_target.tree_exiting.disconnect(_on_target_tree_exiting)
	
	_current_target = target
	_is_root = is_root
	
	if _current_target != null:
		_current_target.tree_exiting.connect(_on_target_tree_exiting)
		_halo_manager.attach_to_target(_current_target)
	else:
		_halo_manager.detach()


func get_target() -> CanvasItem:
	return _current_target


func is_root() -> bool:
	return _is_root


func get_shift_pressed() -> bool:
	return _shift_pressed


func get_ctrl_pressed() -> bool:
	return _ctrl_pressed


func clear_target() -> void:
	set_target(null)


func add_button(tool: HaloTool) -> void:
	_halo_manager.add_external_button(tool)


func _on_target_tree_exiting() -> void:
	if _current_target != null:
		if _current_target.tree_exiting.is_connected(_on_target_tree_exiting):
			_current_target.tree_exiting.disconnect(_on_target_tree_exiting)
	clear_target()
