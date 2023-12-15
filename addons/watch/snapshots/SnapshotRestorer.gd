extends Node
class_name SnapshotRestorer

var snapshot: Snapshot
var restored_objects = {}

static func root_of(snapshot: Snapshot):
	var restorer = SnapshotRestorer.new()
	restorer.snapshot = snapshot
	return restorer.restore_root()

func restore_root():
	return restore(snapshot.root)

func restore(variant: Variant):
	if variant is Array:
		return restore_array(variant)
	if variant is Dictionary:
		return restore_dictionary(variant)
	if variant is ObjectReference:
		return restore_object(variant.id)
	return variant

func restore_array(array: Array):
	var copy = []
	copy.resize(len(array))
	for index in range(len(copy)):
		copy[index] = restore(array[index])
	return copy

func restore_dictionary(dictionary: Dictionary):
	var copy = {}
	for key in dictionary:
		copy[restore(key)] = restore(dictionary[key])
	return copy

func restore_object(id: int):
	if id in restored_objects:
		return restored_objects[id]
	var dict = snapshot.objects[id]
	var object = str_to_var(dict[Snapshot.STR_KEY])
	restored_objects[id] = object
	if object is Resource:
		return object
	for key in dict:
		if key == Snapshot.STR_KEY:
			continue
		if key == Snapshot.CHILDREN_KEY:
			set_children(object as Node, dict[key])
			continue
		object.set(key, restore(dict[key]))
	return object

func set_children(node: Node, children: Array):
	for child in node.get_children():
		node.remove_child(child)
	for child in children:
		node.add_child(restore(child))
