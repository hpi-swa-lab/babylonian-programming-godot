extends Object
class_name ObjectReference

var id: int

func _init(_id: int):
	id = _id

func _to_string():
	return "Ref(" + str(id) + ")"
