extends Node
class_name WatchManager

var watches: Array[Watch] = []
var current_parent: Node = null:
	set(node):
		if current_parent == node:
				return
		for watch in watches:
			watch.remove_annotation()
		if node != null:
			for watch in watches:
				watch.create_annotation(node)
		current_parent = node

var plugin = null

func on_watch(source: String, line: int, value: Variant, group):
	var watch = find_or_create_watch_for(source, line)
	watch.update_value(value, group)

func find_or_create_watch_for(source: String, line: int) -> Watch:
	for watch in watches:
		if watch.source == source and watch.line == line:
			if current_parent != null:
				watch.create_annotation(current_parent)
			return watch
	var watch = Watch.new()
	watch.source = source
	watch.line = line
	watch.plugin = plugin
	watches.append(watch)
	if current_parent != null:
		watch.create_annotation(current_parent)
	return watch

func update():
	Utils.update_and_prune_to_be_removed(watches)

func on_exit():
	for watch in watches:
		watch.remove_annotation()
