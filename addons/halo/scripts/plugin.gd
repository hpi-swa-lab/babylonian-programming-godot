@tool
class_name HaloPlugin extends EditorPlugin

func _enter_tree():
	var selection = get_editor_interface().get_selection()
	selection.selection_changed.connect(_on_selection_changed)

func _on_selection_changed():
	var selection = get_editor_interface().get_selection()
	for node in selection.get_selected_nodes():
		print("Selected node: ", node.name)
		
