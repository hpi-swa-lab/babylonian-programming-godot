class_name Probe

var source: String
var line: int
var plugin: EditorPlugin
var to_be_removed = false
var probe_groups = {}

func belongs_to_current_script() -> bool:
	if plugin == null:
		return true
	var current_script = plugin.get_editor_interface().get_script_editor().get_current_script()
	if current_script == null:
		return false
	return current_script.resource_path == source

func update():
	Utils.update_and_prune_to_be_removed(probe_groups)

func update_value(value, group):
	var key = Utils.group_key(group)
	var probe_group = probe_groups.get(key)
	if probe_group == null:
		probe_group = ProbeGroup.new()
		probe_group.probe = self
		probe_group.group = group
		probe_groups[key] = probe_group
	probe_group.update_value(value)

func create_annotation(parent: Node):
	for probe_group in probe_groups.values():
		probe_group.create_annotation(parent)

func remove_annotation():
	for probe_group in probe_groups.values():
		probe_group.remove_annotation()
