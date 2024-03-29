class_name Utils extends Object

static func group_key(group):
	var key = group
	if group is Object:
		key = group.get_instance_id()
	return key

static func get_keys(container):
	var keys = []
	if container is Array:
		keys = range(len(container))
	if container is Dictionary:
		keys = container
	return keys

static func update_and_prune_to_be_removed(container):
	var to_be_removed = []
	for key in get_keys(container):
		var element = container[key]
		element.update()
		if element.to_be_removed:
			to_be_removed.append(key)
	for i in range(len(to_be_removed) - 1, 0, -1):
		var key = to_be_removed[i]
		fast_remove(container, key)

static func fast_remove(container, key):
	if container is Array:
		swap_remove(container, key)
	if container is Dictionary:
		container.erase(key)

static func swap_remove(array: Array, index: int):
	var last = len(array) - 1
	if index != last:
		array[index] = array[last]
	array.resize(last)

static func is_descendant(descendant: Node, root: Node):
	if descendant == root:
		return true
	var path = descendant.get_path_to(root)
	return path.get_name(0) == ".."
