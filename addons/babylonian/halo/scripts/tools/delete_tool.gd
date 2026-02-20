class_name DeleteTool
extends HaloTool


func _init() -> void:
	self.name = "Delete"
	self.description = "Remove the selected node"
	self.color = Color.FIREBRICK
	self.icon = icon_from_atlas(2, 4)

func start_interaction() -> void:
	var target = Halo.get_target()
	Halo.clear_target()
	Halo.persistence.delete_node(target)
