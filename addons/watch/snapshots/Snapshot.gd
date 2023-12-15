extends Object
class_name Snapshot

var root: Variant
var objects = {}

const STR_KEY = "$str"
const CHILDREN_KEY = "$children"
const SKIPPED_KEYS = [
	"script",
	"owner",
	"scene_file_path",
	"global_position",
	"global_rotation",
	"global_scale",
	"global_skew",
	"global_transform",
]

static func take(object: Object):
	var snapshot = Snapshot.new()
	snapshot.add_root(object)
	return snapshot

func _to_string():
	return str({"root": root, "objects": objects})

func add_root(object: Object):
	root = add(object)

func add(variant: Variant):
	if variant is Array:
		return add_array(variant)
	if variant is Dictionary:
		return add_dictionary(variant)
	if variant is Object:
		return add_object(variant)
	return variant

func add_array(array: Array):
	var copy = []
	copy.resize(len(array))
	for index in range(len(copy)):
		copy[index] = add(array[index])
	return copy

func add_dictionary(dictionary: Dictionary):
	var copy = {}
	for key in dictionary:
		copy[add(key)] = add(dictionary[key])
	return copy

func add_object(object: Object):
	var id = object.get_instance_id()
	var reference = ObjectReference.new(id)
	if id in objects:
		return reference
	var dict = {}
	objects[id] = dict
	dict[STR_KEY] = var_to_str(object)
	for property in object.get_property_list():
		if property["usage"] & (PROPERTY_USAGE_GROUP | PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SUBGROUP) != 0:
			continue
		var key = property["name"]
		if key in SKIPPED_KEYS:
			continue
		var value = object.get(key)
		dict[key] = add(value)
	if object is Node:
		dict[CHILDREN_KEY] = add(object.get_children())
	return reference

func restore():
	return SnapshotRestorer.root_of(self)
