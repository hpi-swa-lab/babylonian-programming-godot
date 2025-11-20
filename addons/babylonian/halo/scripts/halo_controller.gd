extends Node

const MOUSE_BUTTON: int = MOUSE_BUTTON_MIDDLE

var _target_finder: TargetFinder


func _ready() -> void:
	set_process_input(true)
	_target_finder = TargetFinder.new().init()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON and event.pressed:
		_handle_selection_input(event)


func _handle_selection_input(event: InputEventMouseButton) -> void:
	var scene_root: Node = _get_scene_root()
	print("Scene root: ", scene_root, " Type: ", scene_root.get_class())
	print("Scene root children count: ", scene_root.get_child_count())
	var current_target: CanvasItem = Halo.get_target()
	var target: CanvasItem = _target_finder.find_target(scene_root, current_target, event.position)
	print("[HALO] found target: ", target)
	
	if target != null:
		var is_root = (target == scene_root)
		Halo.set_target(target, is_root)


func _get_scene_root() -> Node:
	var root = get_tree().get_root()
	return root.get_child(root.get_child_count() - 1)
