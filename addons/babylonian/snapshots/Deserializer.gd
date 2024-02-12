class_name Deserializer extends Object

var objects: Dictionary
var deserialized_objects = {}
var tree: SceneTree

static func deserialize_json(json: Dictionary, parent: Node):
	var deserializer = Deserializer.new()
	deserializer.tree = parent.get_tree()
	return deserializer.deserialize(json, parent)

func deserialize(serialized: Dictionary, parent: Node):
	objects = serialized["objects"]
	return deserialize_variant(serialized["root"], parent)

func deserializer_error(type: String, value: Variant):
	push_error("Cannot deserialize " + value + " of type " + type)
	return null

func deserialize_variant(variant: Variant, parent = null):
	var type = typeof(variant)
	match type:
		TYPE_NIL:
			return deserialize_nil(variant)
		TYPE_BOOL:
			return deserialize_bool(variant)
		TYPE_FLOAT:
			return deserialize_float(variant)
		TYPE_STRING:
			return deserialize_string(variant)
		TYPE_DICTIONARY:
			return deserialize_type_wrapped(variant, parent)
		TYPE_ARRAY:
			return deserialize_array(variant, parent)
		_:
			return deserializer_error(type, variant)

func unwrap(variant: Dictionary):
	return variant["$value"]

func deserialize_type_wrapped(variant: Dictionary, parent = null):
	var type = variant["$type"]
	var value = variant["$value"]
	match type:
		"int":
			return deserialize_int(value)
		"Vector2":
			return deserialize_vector2(value)
		"Vector2i":
			return deserialize_vector2i(value)
		"Rect2":
			return deserialize_rect2(value)
		"Rect2i":
			return deserialize_rect2i(value)
		"Vector3":
			return deserialize_vector3(value)
		"Vector3i":
			return deserialize_vector3i(value)
		"Transform2D":
			return deserialize_transform2d(value)
		"Vector4":
			return deserialize_vector4(value)
		"Vector4i":
			return deserialize_vector4i(value)
		"Plane":
			return deserialize_plane(value)
		"Quaternion":
			return deserialize_quaternion(value)
		"AABB":
			return deserialize_aabb(value)
		"Basis":
			return deserialize_basis(value)
		"Transform3D":
			return deserialize_transform3d(value)
		"Projection":
			return deserialize_projection(value)
		"Color":
			return deserialize_color(value)
		"StringName":
			return deserialize_string_name(value)
		"NodePath":
			return deserialize_node_path(value)
		"Object":
			return deserialize_object(value, parent)
		"Callable":
			return deserialize_callable(value)
		"Signal":
			return deserialize_signal(value)
		"Dictionary":
			return deserialize_dictionary(value)
		"PackedByteArray":
			return deserialize_packed_byte_array(value)
		"PackedInt32Array":
			return deserialize_packed_int32_array(value)
		"PackedInt64Array":
			return deserialize_packed_int64_array(value)
		"PackedFloat32Array":
			return deserialize_packed_float32_array(value)
		"PackedFloat64Array":
			return deserialize_packed_float64_array(value)
		"PackedStringArray":
			return deserialize_packed_string_array(value)
		"PackedVector2Array":
			return deserialize_packed_vector2_array(value)
		"PackedVector3Array":
			return deserialize_packed_vector3_array(value)
		"PackedColorArray":
			return deserialize_packed_color_array(value)
		_:
			return deserializer_error(type, value)

func deserialize_nil(variant):
	return null

func deserialize_bool(variant: bool):
	return variant

func deserialize_int_value(value: String):
	return int(value)

func deserialize_int(variant: String):
	return deserialize_int_value(variant)

func deserialize_float(variant: float):
	return variant

func deserialize_string(variant: String):
	return variant

func deserialize_vector2(variant: Dictionary):
	return Vector2(
		variant["x"],
		variant["y"],
	)

func deserialize_vector2i(variant: Dictionary):
	return Vector2i(
		deserialize_int_value(variant["x"]),
		deserialize_int_value(variant["y"]),
	)

func deserialize_rect2(variant: Dictionary):
	return Rect2(
		deserialize_vector2(unwrap(variant["position"])),
		deserialize_vector2(unwrap(variant["size"])),
	)

func deserialize_rect2i(variant: Dictionary):
	return Rect2i(
		deserialize_vector2i(unwrap(variant["position"])),
		deserialize_vector2i(unwrap(variant["size"])),
	)

func deserialize_vector3(variant: Dictionary):
	return Vector3(
		variant["x"],
		variant["y"],
		variant["z"],
	)

func deserialize_vector3i(variant: Dictionary):
	return Vector3i(
		deserialize_int_value(variant["x"]),
		deserialize_int_value(variant["y"]),
		deserialize_int_value(variant["z"]),
	)

func deserialize_transform2d(variant: Dictionary):
	return Transform2D(
		deserialize_vector2(unwrap(variant["x"])),
		deserialize_vector2(unwrap(variant["y"])),
		deserialize_vector2(unwrap(variant["origin"])),
	)

func deserialize_vector4(variant: Dictionary):
	return Vector4(
		variant["x"],
		variant["y"],
		variant["z"],
		variant["w"],
	)

func deserialize_vector4i(variant: Dictionary):
	return Vector4i(
		deserialize_int_value(variant["x"]),
		deserialize_int_value(variant["y"]),
		deserialize_int_value(variant["z"]),
		deserialize_int_value(variant["w"]),
	)

func deserialize_plane(variant: Dictionary):
	return Plane(
		variant["x"],
		variant["y"],
		variant["z"],
		variant["d"],
	)

func deserialize_quaternion(variant: Dictionary):
	return Quaternion(
		variant["x"],
		variant["y"],
		variant["z"],
		variant["w"],
	)

func deserialize_aabb(variant: Dictionary):
	return AABB(
		deserialize_vector3(unwrap(variant["position"])),
		deserialize_vector3(unwrap(variant["size"])),
	)

func deserialize_basis(variant: Dictionary):
	return Basis(
		deserialize_vector3(unwrap(variant["x"])),
		deserialize_vector3(unwrap(variant["y"])),
		deserialize_vector3(unwrap(variant["z"])),
	)

func deserialize_transform3d(variant: Dictionary):
	return Transform3D(
		deserialize_basis(unwrap(variant["basis"])),
		deserialize_vector3(unwrap(variant["origin"])),
	)

func deserialize_projection(variant: Dictionary):
	return Projection(
		deserialize_vector4(unwrap(variant["x"])),
		deserialize_vector4(unwrap(variant["y"])),
		deserialize_vector4(unwrap(variant["z"])),
		deserialize_vector4(unwrap(variant["w"])),
	)

func deserialize_color(variant: Dictionary):
	return Color(
		variant["r"],
		variant["g"],
		variant["b"],
		variant["a"],
	)

func deserialize_string_name(variant: String):
	return StringName(variant)

func deserialize_node_path(variant: String):
	return NodePath(variant)

func deserialize_rid(variant: Variant):
	return deserializer_error("RID", variant)

var special_setters = {
	"$signals": set_signals,
	"$groups": set_groups,
	"$is_playing": set_is_playing,
}

func deserialize_object(id: String, parent: Node = null):
	id = deserialize_string(id)
	if id in deserialized_objects:
		return deserialized_objects[id]
	var properties = objects[id]
	var object = str_to_var(properties["$str"])
	deserialized_objects[id] = object
	if object is Resource:
		return object
	var set_properties = func():
		for key in properties:
			if key == "$str":
				continue
			if key in special_setters:
				special_setters[key].call(object, deserialize_variant(properties[key]))
				continue
			set_key(object, key, deserialize_variant(properties[key]))
	if object is Node and parent != null:
		set_children(object, properties["$children"])
		object.name = deserialize_variant(properties["name"])
		parent.add_child(object)
		set_properties.call_deferred()
	else:
		set_properties.call()
	return object

func set_children(node: Node, children: Array):
	for child in node.get_children():
		node.remove_child(child)
	deserialize_variant(children, node)

func set_signals(object: Object, signals: Dictionary):
	for signal_description in object.get_signal_list():
		var name = signal_description["name"]
		var connections = object.get_signal_connection_list(name)
		for connection in connections:
			object.disconnect(name, connection["callable"])
	for name in signals:
		var connections = signals[name]
		for connection in connections:
			object.connect(name, connection["callable"], connection["flags"])

func set_groups(node: Node, groups: Array):
	for group in node.get_groups():
		node.remove_from_group(group)
	for group in groups:
		node.add_to_group(group)

func set_is_playing(node: Node, is_playing: bool):
	if is_playing:
		node.play()
	else:
		node.stop()

func set_key(object: Object, key: String, value: Variant):
	if object is Camera2D and key == "custom_viewport" and value == null:
		return
	object.set(key, value)

func deserialize_callable(variant: Dictionary):
	var object = deserialize_variant(variant["object"])
	var method = deserialize_string_name(unwrap(variant["method"]))
	if object == null and method == &"":
		return Callable()
	return Callable(object, method)

func deserialize_signal(variant: Dictionary):
	var object = deserialize_variant(variant["object"])
	var name = deserialize_string_name(unwrap(variant["name"]))
	if object == null and name == &"":
		return Signal()
	return Signal(object, name)

func deserialize_dictionary(variant: Dictionary):
	var copy = {}
	for key in variant:
		copy[key] = deserialize_variant(variant[key])
	return copy

func deserialize_array(variant: Array, parent = null):
	var copy = []
	copy.resize(len(variant))
	for index in range(len(copy)):
		copy[index] = deserialize_variant(variant[index], parent)
	return copy

func deserialize_packed_byte_array(variant: Array):
	return PackedByteArray(variant)

func deserialize_packed_int32_array(variant: Array):
	return PackedInt32Array(variant)

func deserialize_packed_int64_array(variant: Array):
	var copy = []
	copy.resize(len(variant))
	for index in range(len(variant)):
		copy[index] = deserialize_int_value(variant[index])
	return PackedInt64Array(copy)

func deserialize_packed_float32_array(variant: Array):
	return PackedFloat32Array(variant)

func deserialize_packed_float64_array(variant: Array):
	return PackedFloat64Array(variant)

func deserialize_packed_string_array(variant: Array):
	return PackedStringArray(variant)

func deserialize_packed_vector2_array(variant: Array):
	var copy = []
	copy.resize(len(variant))
	for index in range(len(variant)):
		copy[index] = deserialize_vector2(unwrap(variant[index]))
	return PackedVector2Array(copy)

func deserialize_packed_vector3_array(variant: Array):
	var copy = []
	copy.resize(len(variant))
	for index in range(len(variant)):
		copy[index] = deserialize_vector3(unwrap(variant[index]))
	return PackedVector3Array(copy)

func deserialize_packed_color_array(variant: Array):
	var copy = []
	copy.resize(len(variant))
	for index in range(len(variant)):
		copy[index] = deserialize_color(unwrap(variant[index]))
	return PackedColorArray(copy)
