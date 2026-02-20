class_name CopyTool
extends HaloTool

const COPY_OFFSET: Vector2 = Vector2(10, 10)


func _init() -> void:
	self.name = "Copy"
	self.description = "Duplicate the selected node"
	self.color = Color.ORANGE
	self.icon = icon_from_atlas(4, 5)


func start_interaction() -> void:
	self._button.modulate = Color.DARK_RED
	
	var target = Halo.get_target()
	if target.scene_file_path.is_empty():
		push_warning("Target '" + target + "' has no scene file.")
		Halo.finish_previous_tool_interaction()
		return

	var copy: CanvasItem = load(target.scene_file_path).instantiate()
	var new_name = "New" + target.name
	while Halo.get_tree().get_root().find_child(new_name, true, false) != null:
		new_name = "New" + new_name
	copy.name = new_name
	copy.global_position = target.global_position + COPY_OFFSET
	target.get_parent().add_child(copy)
	Halo.persistence.create_node(copy)
	Halo.persistence.set_property(copy, "global_position")
	Halo.set_target(copy)
	Halo.finish_previous_tool_interaction()


func finish_interaction() -> void:
	self._button.modulate = Color.ORANGE
