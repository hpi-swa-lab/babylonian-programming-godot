extends HBoxContainer
class_name ExampleSlot

signal save_example_slot(index: int, suggested_name: String)
signal restore_example_slot(index: int)
signal delete_example_slot(index: int)

var index: set = set_index
var is_last = false: set = set_is_last
var has_snapshot = false
var has_recording = false
var example_name: get = get_example_name, set = set_example_name

func set_index(new_index: int):
	index = new_index
	update_index_text()

func set_is_last(new_is_last: bool):
	is_last = new_is_last
	update_index_text()

func update_index_text():
	var text = str(index + 1)
	var kind = ""
	if has_snapshot:
		kind += "S"
	if has_recording:
		if kind != "":
			kind += " + "
		kind += "R"
	text += " (" + kind + ")"
	if is_last:
		text += " [last]"
	$Index.text = text

func get_example_name():
	return $Name.text

func set_example_name(new_name: String):
	$Name.text = new_name

func _on_save_button_pressed():
	save_example_slot.emit(index, example_name)

func _on_restore_button_pressed():
	restore_example_slot.emit(index)

func _on_delete_button_pressed():
	delete_example_slot.emit(index)
