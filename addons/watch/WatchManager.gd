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

func on_watch(source: String, line: int, value: Variant):
	var watch = find_or_create_watch_for(source, line)
	watch.update_value(value)

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
	var to_be_removed = []
	for index in range(len(watches)):
		var watch = watches[index]
		watch.update()
		if watch.to_be_removed:
			to_be_removed.append(index)
	for i in range(len(to_be_removed) - 1, 0, -1):
		var index = to_be_removed[i]
		swap_remove(watches, index)

static func swap_remove(array: Array, index: int):
	var last = len(array) - 1
	if index != last:
		array[index] = array[last]
	array.resize(last)

func on_exit():
	for watch in watches:
		watch.remove_annotation()
