class_name HaloController extends Node

const HALO_SELECTION_KEY: int = MOUSE_BUTTON_MIDDLE
const MAX_DISTANCE: int = 5.0


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == HALO_SELECTION_KEY and event.pressed:
		self._handle_selection_input(event)


func _handle_selection_input(event: InputEventMouseButton) -> void:
	var target: Node2D = self._find_target(event.position)
	Halo.set_target(target)


func _find_target(screen_pos: Vector2) -> Node2D:
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return null
	
	var world_pos = camera.get_canvas_transform().affine_inverse() * screen_pos
	var target = self._find_target_by_distance(world_pos)
	if target == null:
		target = self._find_target_by_query(world_pos)
		
	return self._get_selectable_parent(target) if target else null


func _find_target_by_query(world_pos: Vector2) -> Node2D:
	# use engines physics engine and query collision
	var space_state = get_tree().get_root().get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = world_pos
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var hits = space_state.intersect_point(query)
	return hits[0].collider if hits.size() > 0 else null


func _find_target_by_distance(world_pos: Vector2) -> Node2D:
	# calculate distance to each object and select minimum
	var best_target: Node2D = null
	var best_distance = INF
	
	var queue: Array[Node] = [get_tree().get_root()]
	while not queue.is_empty():
		var node = queue.pop_front()
		queue.append_array(node.get_children())
		
		if node is Node2D and not node is TileMapLayer:
			var distance = (node as Node2D).global_position.distance_to(world_pos)
			if distance < best_distance and distance < MAX_DISTANCE:
				best_distance = distance
				best_target = node
	
	return best_target


func _get_selectable_parent(node: Node2D) -> Node2D:
	# exclude Halo, its children and TileMapLayer from selection
	if node == Halo or Halo.is_ancestor_of(node) or node is TileMapLayer:
		return null

	# use game as root, could be game dependant?
	var root = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
	var old_target = Halo.get_target()

	var current = node
	var parent = node.get_parent()
	while parent and parent is Node2D:
		if parent == root or parent == old_target:
			return current

		current = parent
		parent = parent.get_parent()

	return current
