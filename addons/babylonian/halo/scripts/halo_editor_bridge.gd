@tool
class_name HaloEditorBridge
extends EditorDebuggerPlugin

var undo_engine: EditorUndoRedoManager

# maps game-side node paths to editor node paths
var _node_path_mapping: Dictionary = {}


func _init() -> void:
	self._node_path_mapping = {}


func _has_capture(capture: String) -> bool:
	return capture == "halo"


func _capture(message: String, data: Array, _session_id: int) -> bool:
	# todo: get correct scene (look which scene actually is played, instead of just opened in the editor)
	var root = EditorInterface.get_edited_scene_root()
	if root == null:
		return false

	var action: HaloAction = _action_from_message(message, data)
	if action == null:
		return false

	var success = action.apply_to_editor(undo_engine, root, _node_path_mapping)
	if not success:
		push_warning("Action could not be applied: " + action.summary())
	# return true to avoid "unknown message" warnings
	return true


func _action_from_message(message: String, data: Array) -> HaloAction:
	match message:
		"halo:set_property":
			# data: [node_path, property, new_value]
			return SetPropertyAction.new(str(data[0]), str(data[1]), data[2])

		"halo:create_node":
			# data: [parent_path, node_class, node_name, scene_file_path?]
			var scene_path = str(data[3]) if data.size() > 3 else ""
			var action = CreateNodeAction.new(str(data[2]), str(data[0]), scene_path)
			action.node_class = str(data[1])
			return action

		"halo:delete_node":
			# data: [parent_path/node_name]
			var full_path: String = str(data[0])
			var parent_path = full_path.get_base_dir()
			var node_nm = full_path.get_file()
			return DeleteNodeAction.new(node_nm, parent_path)

	return null
