class_name Snapshots extends Node

func snapshot_target():
	return get_tree().current_scene

func set_snapshot_target(node: Node):
	get_tree().current_scene = node

func take_snapshot():
	return Serializer.serialize_to_json(snapshot_target())

func restore_snapshot(snapshot):
	var restored = Deserializer.deserialize_json(snapshot)
	Utils.full_replace_by(snapshot_target(), restored)
	set_snapshot_target(restored)
