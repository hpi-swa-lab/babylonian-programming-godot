class_name HaloAction
extends RefCounted

var saved: bool = false
var node_name: String


func apply(_tree: SceneTree) -> void:
	pass


func inverse() -> HaloAction:
	return null


func serialize(_tree: SceneTree) -> Array:
	return []


func apply_to_editor(_undo_engine: EditorUndoRedoManager, _root: Node, _path_map: Dictionary) -> bool:
	return false


func summary() -> String:
	return self.node_name


static func find_in_game(tree: SceneTree, name: String) -> Node:
	var scene = tree.current_scene
	if scene == null:
		return null
	if scene.name == name:
		return scene
	return scene.find_child(name, true, false)


static func find_in_editor(node_path: String, root: Node, path_map: Dictionary) -> Node:
	var mapped: String = path_map.get(node_path, "")
	if mapped != "":
		return root.get_node_or_null(mapped)

	var parts = node_path.split("/")
	if parts.size() < 3:
		push_warning("Node not found (bad path): " + node_path)
		return null

	# check if root is from correct scene
	var scene_name = parts[2]
	var root_scene_name = root.scene_file_path.get_basename().get_file()
	if root_scene_name != scene_name and root.name != scene_name:
		push_warning("Wrong scene active: message is for '%s' but active scene is '%s' — switch scene tabs in the editor" % [scene_name, root_scene_name])
		return null

	if parts.size() == 3:
		return root

	var relative = "/".join(parts.slice(3))
	var by_path = root.get_node_or_null(relative)
	if by_path:
		return by_path

	var by_name = root.find_child(node_path.get_file(), true, false)
	if by_name:
		return by_name

	push_warning("Node not found: " + node_path)
	return null
