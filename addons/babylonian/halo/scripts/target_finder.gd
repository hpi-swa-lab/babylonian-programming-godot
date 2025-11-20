class_name TargetFinder extends RefCounted

const MAX_DISTANCE: int = 32

func init() -> TargetFinder:
	return self

func find_target_above(root: Node, halo_target: CanvasItem, screen_pos: Vector2) -> CanvasItem:
	return _find_target(root, halo_target, screen_pos, true, false, false)

func find_target_below(root: Node, halo_target: CanvasItem, screen_pos: Vector2) -> CanvasItem:
	return _find_target(root, halo_target, screen_pos, false, true, false)

func find_target(root: Node, halo_target: CanvasItem, screen_pos: Vector2) -> CanvasItem:
	return _find_target(root, halo_target, screen_pos, false, false, false)

func _get_world_position(screen_position: Vector2) -> Vector2:
	var cam = Halo.get_viewport().get_camera_2d()
	if cam == null:
		push_warning("No Camera2D found in viewport; cannot convert click to world coordinates.")
		return Vector2.INF
	return cam.get_canvas_transform().affine_inverse() * screen_position

func _find_area_target(world_position: Vector2, root: Node, exclude_root: bool = false) -> CanvasItem:
	var space_state = Halo.get_world_2d().direct_space_state
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

func _find_point_target(world_position: Vector2, root: Node, exclude_root: bool = false) -> CanvasItem:
	var best_target: CanvasItem = null
	var best_distance = INF
	
	var queue: Array[Node] = [root]
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
		if distance < best_distance and distance < MAX_DISTANCE:
			best_distance = distance
			best_target = node

	return best_target

func _find_parent_target(node: CanvasItem) -> CanvasItem:
	var parent: Node = node.get_parent()
	while parent is not CanvasItem:
		parent = parent.get_parent()
		if not parent:
			return node
	return parent

func _find_target(root: Node, halo_target: CanvasItem, screen_pos: Vector2, go_up: bool, go_down: bool, exclude_root: bool = false) -> CanvasItem:
	var world_pos = _get_world_position(screen_pos)
	print("World pos: ", world_pos, " from screen pos: ", screen_pos)
	var point_target: CanvasItem = _find_point_target(world_pos, root, exclude_root)
	var area_target: CanvasItem = _find_area_target(world_pos, root, exclude_root)
	print("Point target: ", point_target, " Area target: ", area_target)
	
	if not halo_target:
		if point_target:
			return point_target
		return area_target
		
	elif go_up:
		return _find_parent_target(halo_target)
		
	elif go_down:
		return _find_target(halo_target, halo_target, screen_pos, false, false, true)
		
	elif halo_target in [area_target, point_target]:
		if halo_target == area_target:
			return point_target
		else:
			return area_target

	elif point_target:
		return point_target
		
	elif area_target:
		return area_target
		
	else:
		return null
