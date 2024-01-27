class_name Watch

var source: String
var line: int
var plugin: EditorPlugin
var to_be_removed = false
var watch_groups = {}

func belongs_to_current_script() -> bool:
	if plugin == null:
		return true
	var current_script = plugin.get_editor_interface().get_script_editor().get_current_script()
	if current_script == null:
		return false
	return current_script.resource_path == source

func update():
	Utils.update_and_prune_to_be_removed(watch_groups)

func update_value(value, group):
	var key = Utils.group_key(group)
	var watch_group = watch_groups.get(key)
	if watch_group == null:
		watch_group = WatchGroup.new()
		watch_group.watch = self
		watch_group.group = group
		watch_groups[key] = watch_group
	watch_group.update_value(value)

func create_annotation(parent: Node):
	for watch_group in watch_groups.values():
		watch_group.create_annotation(parent)

func remove_annotation():
	for watch_group in watch_groups.values():
		watch_group.remove_annotation()
