extends Node2D

var halo_target: CanvasItem = null
var halo: Node2D = null

var show_tree_lines: bool = false
var buttons: Dictionary = {}
var next_button_id: int = 0

var undo_stack: Array = []
var redo_stack: Array = []

const MOUSE_BUTTON: int = MOUSE_BUTTON_MIDDLE
const UP_KEY: int = KEY_SHIFT
const DOWN_KEY: int = KEY_CTRL
const MAX_DISTANCE: int = 32
const MODIFIER_KEY: int = KEY_CTRL
const UNDO_KEY: int = KEY_Z
const REDO_KEY: int = KEY_Y

func _ready():
	set_process_input(true)
	
func get_scene_root() -> Node:
	return get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)

func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == self.MOUSE_BUTTON
		and event.pressed
	):
		var scene_root: Node = self.get_scene_root()
		var up_key_pressed: bool = Input.is_key_pressed(self.UP_KEY)
		var down_key_pressed: bool = Input.is_key_pressed(self.DOWN_KEY)
		var target: CanvasItem = find_target(scene_root, event.position, up_key_pressed, down_key_pressed)
		self.set_target(target, scene_root)
	elif (
		event is InputEventKey
		and event.pressed 
		and Input.is_key_pressed(self.MODIFIER_KEY)
	):
		if event.keycode == self.UNDO_KEY:
			self.undo()
		elif event.keycode == self.REDO_KEY:
			self.redo()
			
func undo() -> void:
	var scene_root: Node = self.get_scene_root()
	if self.undo_stack.is_empty():
		self.set_target(null, scene_root, true)
	var new_target: CanvasItem = self.undo_stack.pop_back()
	if scene_root.is_ancestor_of(new_target) and is_instance_valid(new_target):
		self.redo_stack.push_back(self.halo_target)
		self.set_target(new_target, scene_root, true)
	else:
		self.undo_stack.clear()
	
func redo() -> void:
	if self.redo_stack.is_empty():
		return
	var scene_root: Node = self.get_scene_root()
	var new_target: CanvasItem = self.redo_stack.pop_back()
	if scene_root.is_ancestor_of(new_target) and is_instance_valid(new_target):
		self.undo_stack.push_back(self.halo_target)
		self.set_target(new_target, scene_root, true)
	else:
		self.redo_stack.clear()
			
func get_world_position(screen_position: Vector2) -> Vector2:
	var cam = get_viewport().get_camera_2d()
	if cam == null:
		push_warning("No Camera2D found in viewport; cannot convert click to world coordinates.")
		return Vector2.INF
	return cam.get_canvas_transform().affine_inverse() * screen_position
	
func find_area_target(world_position: Vector2, root: Node, exclude_root: bool = false) -> CanvasItem:
	var space_state = get_world_2d().direct_space_state
	var parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	parameters.position = world_position
	parameters.collide_with_areas = true
	var hits = space_state.intersect_point(parameters)
	for hit in hits:
		var collider: CanvasItem = hit.collider
		if (
			collider is Halo 
			or collider.get_parent() is Halo
			or not root.is_ancestor_of(collider)
		):
			continue
		if exclude_root and collider == root:
			continue
		return collider
	return null
	
func find_point_target(world_position: Vector2, root: Node, exclude_root: bool = false) -> CanvasItem:
	var best_target: CanvasItem = null
	var best_distance = INF
	
	var queue: Array = [root]
	while not queue.is_empty():
		var node: Node = queue.pop_front()
		if node is Halo:
			continue
		queue.append_array(node.get_children())
		if node is not CanvasItem:
			continue
		if exclude_root and node == root:
			continue
		var distance: float = node.global_position.distance_to(world_position)
		if distance < best_distance and distance < self.MAX_DISTANCE:
			best_distance = distance
			best_target = node

	return best_target
	
func find_parent_target(node: CanvasItem) -> CanvasItem:
	var parent: Node = node.get_parent()
	while parent is not CanvasItem:
		parent = parent.get_parent()
		if not parent:
			return node
	return parent

func find_target(root: Node, screen_pos: Vector2, go_up: bool, go_down: bool, exclude_root: bool = false) -> CanvasItem:
	var world_pos = get_world_position(screen_pos)
	var point_target: CanvasItem = self.find_point_target(world_pos, root, exclude_root)
	var area_target: CanvasItem = self.find_area_target(world_pos, root, exclude_root)
	
	if not self.halo_target:
		if point_target:
			return point_target
		return area_target
		
	elif self.halo_target in [area_target, point_target] and not go_up and not go_down:
		if self.halo_target == area_target:
			return point_target
		else:
			return area_target
			
	elif self.halo_target in [area_target, point_target] and go_up:
		return self.find_parent_target(self.halo_target)
		
	elif self.halo_target in [area_target, point_target] and go_down:
		return self.find_target(self.halo_target, screen_pos, false, false, true)
		
	elif point_target:
		return point_target
		
	else:
		return area_target
		
func put_halo_on(target: CanvasItem) -> void:
	if self.halo_target != target:
		self.set_target(target, self.get_scene_root())

func set_target(target: CanvasItem, scene_root: Node, is_undo_redo: bool = false) -> void:
	if not self.halo:
		self.halo = preload("res://addons/babylonian/halo/scenes/halo.tscn").instantiate()
		scene_root.add_child(self.halo)
		self.halo.get_node("TreeVisibilityButton").button_down.connect(_on_tree_visibility_button_down)
		
	if self.halo_target and not is_undo_redo:
		self.undo_stack.push_back(self.halo_target)
		
	self.halo_target = target
	if target:
		self.halo.set_target(self.halo_target, self.halo_target == scene_root, self.buttons.values())
		self.halo.set_tree_line_visibility(self.show_tree_lines)
		self.halo.visible = true
	else:
		self.halo.visible = false
		
	if not is_undo_redo:
		self.redo_stack.clear()
		
func add_button(texture: Texture2D, callback: Callable, NodeTypes: Array = [], color_modulation: Color = Color.WHITE) -> int:
	var button_signal_handler = func() -> void:
		callback.call(self.halo_target)
	
	var button: TextureButton = TextureButton.new()
	button.texture_normal = texture
	button.modulate = color_modulation
	button.size = Vector2(50, 50)
	button.scale = Vector2(0.2, 0.2)
	button.z_index = 128
	button.pressed.connect(button_signal_handler)
	
	self.buttons[self.next_button_id] = button
	self.next_button_id += 1
	return self.next_button_id - 1
	
func remove_button(button_id: int) -> void:
	self.buttons.erase(button_id)
		
func _on_tree_visibility_button_down() -> void:
	self.show_tree_lines = not self.show_tree_lines
	self.halo.set_tree_line_visibility(self.show_tree_lines)
	
