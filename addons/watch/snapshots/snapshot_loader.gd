extends Node2D

func _process(delta):
	var file = FileAccess.open(InGameUI.snapshot_path, FileAccess.READ)
	var json = file.get_as_text()
	var node = Deserializer.deserialize_json(json)
	Utils.full_replace_by(self, node)
	queue_free()
