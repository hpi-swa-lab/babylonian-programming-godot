class_name DeleteNodeAction
extends HaloAction

var parent_path: String
var scene_file_path: String
var _stored_node: Node  # game-side only, not serialized


func _init(node_name: String = "", parent_path: String = "", scene_file_path: String = "", node: Node = null):
	self.node_name = node_name
	self.parent_path = parent_path
	self.scene_file_path = scene_file_path
	self._stored_node = node


func apply(tree: SceneTree) -> void:
	var node = self._get_live_node(tree)
	if node and node.get_parent():
		if Halo.get_target() == node:
			Halo.clear_target()
		node.get_parent().remove_child(node)
		self._stored_node = node


func inverse() -> HaloAction:
	var cls = self._stored_node.get_class() if self._stored_node and is_instance_valid(self._stored_node) else "Node2D"
	var action = CreateNodeAction.new(self.node_name, self.parent_path, self.scene_file_path)
	action.node_class = cls
	return action


func serialize(_tree: SceneTree) -> Array:
	return ["halo:delete_node", [self.parent_path + "/" + self.node_name]]


func summary() -> String:
	return "Delete " + self.node_name


func apply_to_editor(undo_engine: EditorUndoRedoManager, root: Node, path_map: Dictionary) -> bool:
	var node_key = self.parent_path + "/" + self.node_name
	var node = HaloAction.find_in_editor(node_key, root, path_map)
	if node == null:
		node = root.find_child(self.node_name, true, false)
	if node == null:
		return false

	var parent = node.get_parent()
	undo_engine.create_action("Delete " + node.name)
	undo_engine.add_do_method(parent, "remove_child", node)
	undo_engine.add_undo_method(parent, "add_child", node)
	undo_engine.add_undo_property(node, "owner", root)
	undo_engine.add_undo_reference(node)
	undo_engine.commit_action()

	path_map.erase(node_key)
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
