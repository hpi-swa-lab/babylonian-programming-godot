extends Node2D

var halo_target: CanvasItem = null
var halo: Node2D = null

var show_tree_lines: bool = false

const MOUSE_BUTTON: int = MOUSE_BUTTON_MIDDLE
const UP_KEY: int = KEY_SHIFT
const DOWN_KEY: int = KEY_CTRL
const MAX_DISTANCE: int = 32

func _ready():
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == self.MOUSE_BUTTON
		and event.pressed
	):
		var scene_root: Node = get_tree().current_scene
		var up_key_pressed: bool = Input.is_key_pressed(self.UP_KEY)
		var down_key_pressed: bool = Input.is_key_pressed(self.DOWN_KEY)
		var target: Node = find_target(scene_root, event.position, up_key_pressed, down_key_pressed)
		self.set_target(target)			
			
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

func set_target(target: CanvasItem) -> void:
	if self.halo:
		self.halo.get_node("TreeVisibilityButton").button_down.disconnect(_on_tree_visibility_button_down)
		self.halo.queue_free()
		
	self.halo_target = target
	
	if self.halo_target:
		self.halo = preload("res://addons/halo/scenes/halo.tscn").instantiate()
		self.halo_target.add_child(self.halo)
		self.halo.set_target(self.halo_target)
		self.halo.set_tree_line_visibility(self.show_tree_lines)
		self.halo.get_node("TreeVisibilityButton").button_down.connect(_on_tree_visibility_button_down)
		
func _on_tree_visibility_button_down() -> void:
	self.show_tree_lines = not self.show_tree_lines
	self.halo.set_tree_line_visibility(self.show_tree_lines)
	
