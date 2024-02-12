class_name Serializer extends Object

var objects = {}
var root: Variant

static func serialize_to_json(root: Variant):
	var serializer = Serializer.new()
	serializer.root = root
	var serialized = serializer.serialize()
	return serialized

func serialize():
	return {"root": serialize_variant(root), "objects": objects}

func serialize_variant(variant: Variant):
	match typeof(variant):
		TYPE_NIL:
			return serialize_nil(variant)
		TYPE_BOOL:
			return serialize_bool(variant)
		TYPE_INT:
			return serialize_int(variant)
		TYPE_FLOAT:
			return serialize_float(variant)
		TYPE_STRING:
			return serialize_string(variant)
		TYPE_VECTOR2:
			return serialize_vector2(variant)
		TYPE_VECTOR2I:
			return serialize_vector2i(variant)
		TYPE_RECT2:
			return serialize_rect2(variant)
		TYPE_RECT2I:
			return serialize_rect2i(variant)
		TYPE_VECTOR3:
			return serialize_vector3(variant)
		TYPE_VECTOR3I:
			return serialize_vector3i(variant)
		TYPE_TRANSFORM2D:
			return serialize_transform2d(variant)
		TYPE_VECTOR4:
			return serialize_vector4(variant)
		TYPE_VECTOR4I:
			return serialize_vector4i(variant)
		TYPE_PLANE:
			return serialize_plane(variant)
		TYPE_QUATERNION:
			return serialize_quaternion(variant)
		TYPE_AABB:
			return serialize_aabb(variant)
		TYPE_BASIS:
			return serialize_basis(variant)
		TYPE_TRANSFORM3D:
			return serialize_transform3d(variant)
		TYPE_PROJECTION:
			return serialize_projection(variant)
		TYPE_COLOR:
			return serialize_color(variant)
		TYPE_STRING_NAME:
			return serialize_string_name(variant)
		TYPE_NODE_PATH:
			return serialize_node_path(variant)
		TYPE_RID:
			return serialize_rid(variant)
		TYPE_OBJECT:
			return serialize_object(variant)
		TYPE_CALLABLE:
			return serialize_callable(variant)
		TYPE_SIGNAL:
			return serialize_signal(variant)
		TYPE_DICTIONARY:
			return serialize_dictionary(variant)
		TYPE_ARRAY:
			return serialize_array(variant)
		TYPE_PACKED_BYTE_ARRAY:
			return serialize_packed_byte_array(variant)
		TYPE_PACKED_INT32_ARRAY:
			return serialize_packed_int32_array(variant)
		TYPE_PACKED_INT64_ARRAY:
			return serialize_packed_int64_array(variant)
		TYPE_PACKED_FLOAT32_ARRAY:
			return serialize_packed_float32_array(variant)
		TYPE_PACKED_FLOAT64_ARRAY:
			return serialize_packed_float64_array(variant)
		TYPE_PACKED_STRING_ARRAY:
			return serialize_packed_string_array(variant)
		TYPE_PACKED_VECTOR2_ARRAY:
			return serialize_packed_vector2_array(variant)
		TYPE_PACKED_VECTOR3_ARRAY:
			return serialize_packed_vector3_array(variant)
		TYPE_PACKED_COLOR_ARRAY:
			return serialize_packed_color_array(variant)

func type_wrapped(type: String, value: Variant):
	return {"$type": type, "$value": value}

func serializer_error(type: String, value: Variant):
	push_error("Cannot serialize " + str(value) + " of type " + type)
	return null

func serialize_nil(variant):
	return null

func serialize_bool(variant: bool):
	return variant

func serialize_int_value(value: int):
	return str(value) # 64-bit ints don't fit into JSON floats

func serialize_int(variant: int):
	return type_wrapped("int", serialize_int_value(variant))

func serialize_float(variant: float):
	return variant

func serialize_string(variant: String):
	return variant

func serialize_vector2(variant: Vector2):
	return type_wrapped("Vector2", {
		"x": variant.x,
		"y": variant.y,
	})

func serialize_vector2i(variant: Vector2i):
	return type_wrapped("Vector2i", {
		"x": serialize_int_value(variant.x),
		"y": serialize_int_value(variant.y),
	})

func serialize_rect2(variant: Rect2):
	return type_wrapped("Rect2", {
		"position": serialize_vector2(variant.position),
		"size": serialize_vector2(variant.size),
	})

func serialize_rect2i(variant: Rect2i):
	return type_wrapped("Rect2i", {
		"position": serialize_vector2i(variant.position),
		"size": serialize_vector2i(variant.size),
	})

func serialize_vector3(variant: Vector3):
	return type_wrapped("Vector3", {
		"x": variant.x,
		"y": variant.y,
		"z": variant.z,
	})

func serialize_vector3i(variant: Vector3i):
	return type_wrapped("Vector3i", {
		"x": serialize_int_value(variant.x),
		"y": serialize_int_value(variant.y),
		"z": serialize_int_value(variant.z),
	})

func serialize_transform2d(variant: Transform2D):
	return type_wrapped("Transform2D", {
		"x": serialize_vector2(variant.x),
		"y": serialize_vector2(variant.y),
		"origin": serialize_vector2(variant.origin),
	})

func serialize_vector4(variant: Vector4):
	return type_wrapped("Vector4", {
		"x": variant.x,
		"y": variant.y,
		"z": variant.z,
		"w": variant.w,
	})

func serialize_vector4i(variant: Vector4i):
	return type_wrapped("Vector4i", {
		"x": serialize_int_value(variant.x),
		"y": serialize_int_value(variant.y),
		"z": serialize_int_value(variant.z),
		"w": serialize_int_value(variant.w),
	})

func serialize_plane(variant: Plane):
	return type_wrapped("Plane", {
		"x": variant.x,
		"y": variant.y,
		"z": variant.z,
		"d": variant.d,
	})

func serialize_quaternion(variant: Quaternion):
	return type_wrapped("Quaternion", {
		"x": variant.x,
		"y": variant.y,
		"z": variant.z,
		"w": variant.w,
	})

func serialize_aabb(variant: AABB):
	return type_wrapped("AABB", {
		"position": serialize_vector3(variant.position),
		"size": serialize_vector3(variant.size),
	})

func serialize_basis(variant: Basis):
	return type_wrapped("Basis", {
		"x": serialize_vector3(variant.x),
		"y": serialize_vector3(variant.y),
		"z": serialize_vector3(variant.z),
	})

func serialize_transform3d(variant: Transform3D):
	return type_wrapped("Transform3D", {
		"basis": serialize_basis(variant.basis),
		"origin": serialize_vector3(variant.origin),
	})

func serialize_projection(variant: Projection):
	return type_wrapped("Projection", {
		"x": serialize_vector4(variant.x),
		"y": serialize_vector4(variant.y),
		"z": serialize_vector4(variant.z),
		"w": serialize_vector4(variant.w),
	})

func serialize_color(variant: Color):
	return type_wrapped("Color", {
		"r": variant.r,
		"g": variant.g,
		"b": variant.b,
		"a": variant.a,
	})

func serialize_string_name(variant: StringName):
	return type_wrapped("StringName", variant)

func serialize_node_path(variant: NodePath):
	return type_wrapped("NodePath", str(variant))

func serialize_rid(variant: RID):
	return serializer_error("RID", variant)

const skipped_properties = [
	"script",
	"owner",
	"scene_file_path",
	"global_position",
	"global_rotation",
	"global_rotation_degrees",
	"global_scale",
	"global_skew",
	"global_transform",
]

func serialize_object(object: Object):
	if object == null:
		return null
	if should_serialize_node_reference(object):
		return serialize_node_reference(object)
	var id = str(object.get_instance_id())
	var reference = type_wrapped("Object", serialize_string(id))
	if id in objects:
		return reference
	var properties = {}
	objects[id] = properties
	properties["$str"] = var_to_str(object)
	for property in object.get_property_list():
		if property["usage"] & (PROPERTY_USAGE_GROUP | PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SUBGROUP) != 0:
			continue
		var key = property["name"]
		if key in skipped_properties:
			continue
		var value = object.get(key)
		properties[key] = serialize_variant(value)
	properties["$signals"] = serialize_signals(object)
	if object is Node:
		properties["$children"] = serialize_variant(object.get_children())
		properties["$groups"] = serialize_variant(object.get_groups())
	if object is AnimatedSprite2D or object is AnimatedSprite3D or object is AnimationPlayer:
		properties["$is_playing"] = serialize_variant(object.is_playing())
	if object is Timer:
		properties["$is_stopped"] = serialize_variant(object.is_stopped())
	return reference

func should_serialize_node_reference(object: Object):
	return \
		object is Node and root is Node and \
		object.is_inside_tree() and root.is_inside_tree() and \
		not Utils.is_descendant(object, root)

func serialize_node_reference(node: Node):
	return type_wrapped("Node", serialize_node_path(node.get_path()))

func serialize_signals(object: Object):
	var signals = {}
	for signal_description in object.get_signal_list():
		var name = signal_description["name"]
		var connections = object.get_signal_connection_list(name)
		if len(connections) == 0:
			continue
		signals[name] = connections
	return serialize_variant(signals)

func serialize_callable(variant: Callable):
	return type_wrapped("Callable", {
		"object": serialize_object(variant.get_object()),
		"method": serialize_string_name(variant.get_method()),
	})

func serialize_signal(variant: Signal):
	return type_wrapped("Signal", {
		"object": serialize_object(variant.get_object()),
		"name": serialize_string_name(variant.get_name()),
	})

func serialize_dictionary(variant: Dictionary):
	var copy = {}
	for key in variant:
		copy[key] = serialize_variant(variant[key])
	return type_wrapped("Dictionary", copy)

func serialize_array(variant: Array):
	var copy = []
	copy.resize(len(variant))
	for index in range(len(copy)):
		copy[index] = serialize_variant(variant[index])
	return copy

func serialize_packed_byte_array(variant: PackedByteArray):
	return type_wrapped("PackedByteArray", Array(variant))

func serialize_packed_int32_array(variant: PackedInt32Array):
	return type_wrapped("PackedInt32Array", Array(variant))

func serialize_packed_int64_array(variant: PackedInt64Array):
	var copy = []
	copy.resize(len(variant))
	for index in range(len(variant)):
		copy[index] = serialize_int_value(variant[index])
	return type_wrapped("PackedInt64Array", copy)

func serialize_packed_float32_array(variant: PackedFloat32Array):
	return type_wrapped("PackedFloat32Array", Array(variant))

func serialize_packed_float64_array(variant: PackedFloat64Array):
	return type_wrapped("PackedFloat64Array", Array(variant))

func serialize_packed_string_array(variant: PackedStringArray):
	return type_wrapped("PackedStringArray", Array(variant))

func serialize_packed_vector2_array(variant: PackedVector2Array):
	var copy = []
	copy.resize(len(variant))
	for index in range(len(variant)):
		copy[index] = serialize_vector2(variant[index])
	return type_wrapped("PackedVector2Array", copy)

func serialize_packed_vector3_array(variant: PackedVector3Array):
	var copy = []
	copy.resize(len(variant))
	for index in range(len(variant)):
		copy[index] = serialize_vector3(variant[index])
	return type_wrapped("PackedVector3Array", copy)

func serialize_packed_color_array(variant: PackedColorArray):
	var copy = []
	copy.resize(len(variant))
	for index in range(len(variant)):
		copy[index] = serialize_color(variant[index])
	return type_wrapped("PackedColorArray", copy)
