extends Object
class_name Utils

static func full_replace_by(original: Node, replacement: Node):
	var parent = original.get_parent()
	var index = original.get_index()
	parent.remove_child(original)
	parent.add_child(replacement)
	parent.move_child(replacement, index)
