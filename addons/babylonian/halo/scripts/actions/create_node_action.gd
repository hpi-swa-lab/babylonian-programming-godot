class_name CreateNodeAction
extends HaloAction

var parent_path: String
var node_class: String
var scene_file_path: String
var _stored_node: Node  # game-side only, not serialized


func _init(node_name: String = "", parent_path: String = "", scene_file_path: String = "", node: Node = null):
	self.node_name = node_name
	self.parent_path = parent_path
	self.scene_file_path = scene_file_path
	self._stored_node = node


func apply(tree: SceneTree) -> void:
	if self._stored_node and is_instance_valid(self._stored_node):
		var parent = self._find_parent(tree)
		if parent and not self._stored_node.get_parent():
			parent.add_child(self._stored_node)
	elif not self.scene_file_path.is_empty():
		var parent = self._find_parent(tree)
		if parent:
			var node = load(self.scene_file_path).instantiate()
			node.name = self.node_name
			parent.add_child(node)
			self._stored_node = node


func inverse() -> HaloAction:
	return DeleteNodeAction.new(self.node_name, self.parent_path, self.scene_file_path)


func serialize(tree: SceneTree) -> Array:
	var node = self._get_live_node(tree)
	if not node or not node.get_parent():
		return []
	return ["halo:create_node", [
		str(node.get_parent().get_path()), node.get_class(),
		self.node_name, self.scene_file_path]]


func summary() -> String:
	return "Create " + self.node_name


func apply_to_editor(undo_engine: EditorUndoRedoManager, root: Node, path_map: Dictionary) -> bool:
	var parent = HaloAction.find_in_editor(self.parent_path, root, path_map)
	if parent == null:
		return false

	var new_node: Node
	if not self.scene_file_path.is_empty():
		var packed = load(self.scene_file_path)
		if packed == null:
			return false
		new_node = packed.instantiate()
	else:
		var cls = self.node_class if self.node_class != "" else "Node2D"
		new_node = ClassDB.instantiate(cls)

	# strip file extension
	new_node.name = self.node_name.get_basename() if "." in self.node_name else self.node_name
	
	parent.add_child(new_node)
	new_node.owner = root
	# now get_path() returns an editor-side path
	var game_key = self.parent_path + "/" + self.node_name
	path_map[game_key] = str(new_node.get_path())

	undo_engine.create_action("Create " + new_node.name)
	undo_engine.add_do_method(parent, "add_child", new_node)
	undo_engine.add_do_property(new_node, "owner", root)
	undo_engine.add_do_reference(new_node)
	undo_engine.add_undo_method(parent, "remove_child", new_node)
	undo_engine.add_undo_reference(new_node)
	undo_engine.commit_action(false)
	
	return true


func _find_parent(tree: SceneTree) -> Node:
	var parent = tree.root.get_node_or_null(self.parent_path)
	if parent:
		return parent
	return HaloAction.find_in_game(tree, self.parent_path.get_file())


func _get_live_node(tree: SceneTree) -> Node:
	if self._stored_node and is_instance_valid(self._stored_node) and self._stored_node.get_parent():
		return self._stored_node
	return HaloAction.find_in_game(tree, self.node_name)
