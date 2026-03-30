class_name SetPropertyAction
extends HaloAction

var property: String
var old_value: Variant
var new_value: Variant


func _init(node_name: String, property: String, new_value: Variant, old_value: Variant = null):
	self.node_name = node_name
	self.property = property
	self.new_value = new_value
	self.old_value = old_value


func apply(tree: SceneTree) -> void:
	var node = HaloAction.find_in_game(tree, self.node_name)
	if node:
		node.set(self.property, self.new_value)


func inverse() -> HaloAction:
	if self.old_value == null:
		return null
	# swap old and new value
	return SetPropertyAction.new(self.node_name, self.property, self.old_value, self.new_value)


func serialize(tree: SceneTree) -> Array:
	var node = HaloAction.find_in_game(tree, self.node_name)
	if not node:
		return []
	return ["halo:set_property", [str(node.get_path()), self.property, self.new_value]]


func summary() -> String:
	return "Set " + self.node_name + "." + self.property


func apply_to_editor(undo_engine: EditorUndoRedoManager, root: Node, path_map: Dictionary) -> bool:
	var node = HaloAction.find_in_editor(self.node_name, root, path_map)
	if node == null:
		return false

	undo_engine.create_action("Set " + self.property)
	undo_engine.add_undo_property(node, self.property, node.get(self.property))
	undo_engine.add_do_property(node, self.property, self.new_value)
	undo_engine.commit_action()
	return true
