class_name Snapshots extends Node

func snapshot_target():
	return get_tree().current_scene

func set_snapshot_target(node: Node):
	get_tree().current_scene = node

func take_snapshot():
	return Serializer.serialize_to_json(snapshot_target())

func restore_snapshot(snapshot):
	var current = snapshot_target()
	var parent = current.get_parent()
	var index = current.get_index()
	parent.remove_child(current)
	var restored = Deserializer.deserialize_json(snapshot, parent)
	parent.move_child(restored, index)
	set_snapshot_target(restored)
