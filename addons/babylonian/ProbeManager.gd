class_name ProbeManager extends Node

var probes: Array[Probe] = []
var current_parent: Node = null:
	set(node):
		if current_parent == node:
				return
		for probe in probes:
			probe.remove_annotation()
		if node != null:
			for probe in probes:
				probe.create_annotation(node)
		current_parent = node

var plugin = null

func on_probe(source: String, line: int, value: Variant, group):
	var probe = find_or_create_probe_for(source, line)
	probe.update_value(value, group)

func find_or_create_probe_for(source: String, line: int) -> Probe:
	for probe in probes:
		if probe.source == source and probe.line == line:
			if current_parent != null:
				probe.create_annotation(current_parent)
			return probe
	var probe = Probe.new()
	probe.source = source
	probe.line = line
	probe.plugin = plugin
	probes.append(probe)
	if current_parent != null:
		probe.create_annotation(current_parent)
	return probe

func update():
	Utils.update_and_prune_to_be_removed(probes)

func on_exit():
	for probe in probes:
		probe.remove_annotation()
