class_name Examples extends Control

const examples_path = "res://examples"

var snapshots = Snapshots.new()
var recordings = Recordings.new()

var snapshot_enabled = true
var recording_enabled = false
var save_recorded_examples = false

var example_slots = []
var loop_example_slots = []
var last_example_slot = -1

func _ready():
	for child in [snapshots, recordings]:
		add_child(child)
	recordings.looped_playback_ended.connect(self.looped_playback_ended)
	recordings.theme = theme

func create_example(snapshot, recording):
	return {
		"snapshot": snapshot,
		"recording": recording,
	}

var looped_example

func restore_example(example, loop: bool):
	var snapshot = example["snapshot"]
	var recording = example["recording"]
	if snapshot != null:
		snapshots.restore_snapshot(snapshot)
	if recording != null:
		recordings.playback_recording(recording, loop)
	if loop:
		looped_example = example

func looped_playback_ended():
	restore_example(looped_example, true)

func set_last_example_slot(index):
	if last_example_slot >= 0 and last_example_slot < len(example_slot_uis):
		example_slot_uis[last_example_slot].is_last = false
	last_example_slot = index
	if last_example_slot >= 0:
		example_slot_uis[last_example_slot].is_last = true

func restore_slot(index):
	if index >= len(example_slots):
		return
	restore_example(example_slots[index], loop_example_slots[index])
	set_last_example_slot(index)

func restore_last_example():
	restore_slot(last_example_slot)

func add_example_slot(example):
	example_slots.append(example)
	loop_example_slots.append(false)
	var index = len(example_slots) - 1
	add_example_slot_ui(example, index)
	set_last_example_slot(index)
	return index

@onready var example_slots_container = $ScrollContainer/SlotsContainer
var example_slot_uis = []

func add_example_slot_ui(example, index: int):
	var example_slot = preload("res://addons/babylonian/example_slot.tscn").instantiate()
	example_slot.set_loop_example_slot.connect(self.set_loop_slot)
	example_slot.save_example_slot.connect(self.save_slot)
	example_slot.restore_example_slot.connect(self.restore_slot)
	example_slot.delete_example_slot.connect(self.delete_slot)
	example_slot.index = index
	example_slot.has_snapshot = example["snapshot"] != null
	example_slot.has_recording = example["recording"] != null
	example_slot.example_name = example_name(index)
	example_slots_container.add_child(example_slot)
	example_slot_uis.append(example_slot)
	await get_tree().process_frame
	$ScrollContainer.ensure_control_visible(example_slot)

func delete_slot(index: int):
	example_slots.remove_at(index)
	loop_example_slots.remove_at(index)
	example_slot_uis[index].queue_free()
	example_slot_uis.remove_at(index)
	for index_above in range(index, len(example_slots)):
		example_slot_uis[index_above].index = index_above
	if last_example_slot == index:
		set_last_example_slot(-1)
	elif last_example_slot > index:
		set_last_example_slot(last_example_slot - 1)

func set_loop_slot(index: int, loop: bool):
	loop_example_slots[index] = loop

func example_name(index: int):
	return "Example " + str(index + 1)

func record_example():
	var snapshot = null
	var recording = null
	if snapshot_enabled:
		snapshot = snapshots.take_snapshot()
	if recording_enabled:
		recording = await recordings.do_recording()
	if snapshot == null and recording == null:
		return
	var example = create_example(snapshot, recording)
	var index = add_example_slot(example)
	if save_recorded_examples:
		save_example(example, example_name(index))

func choose_example_path(mode: FileDialog.FileMode, current_file = ""):
	var dialog = FileDialog.new()
	dialog.file_mode = mode
	DirAccess.make_dir_recursive_absolute(examples_path)
	dialog.root_subfolder = examples_path
	dialog.current_file = current_file
	dialog.add_filter("*.json", "JSON")
	add_child(dialog)
	dialog.popup_centered_ratio(0.5)
	return await dialog.file_selected

func example_to_string(example):
	return JSON.stringify({
		"snapshot": example["snapshot"],
		"recording": recordings.recording_to_serializable(example["recording"]),
	}, "    ", false, true)

func example_from_string(json):
	var example = JSON.parse_string(json)
	return {
		"snapshot": example["snapshot"],
		"recording": recordings.recording_from_serializable(example["recording"])
	}

func save_example(example, suggested_name: String):
	var path = await choose_example_path(FileDialog.FILE_MODE_SAVE_FILE, suggested_name + ".json")
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(example_to_string(example))
	file.close()

func save_slot(index: int, suggested_name: String):
	save_example(example_slots[index], suggested_name)

func load_example():
	var path = await choose_example_path(FileDialog.FILE_MODE_OPEN_FILE)
	var file = FileAccess.open(path, FileAccess.READ)
	var json = file.get_as_text()
	var example = example_from_string(json)
	file.close()
	add_example_slot(example)

enum KeyboardState {
	NONE,
	RESTORE,
}

var keyboard_state = KeyboardState.NONE

func _unhandled_input(event):
	if event is InputEventKey:
		if not event.pressed or not event.ctrl_pressed:
			return
		var keycode = event.keycode
		var next_keyboard_state = KeyboardState.NONE
		match keycode:
			KEY_R:
				match keyboard_state:
					KeyboardState.NONE:
						next_keyboard_state = KeyboardState.RESTORE
					KeyboardState.RESTORE:
						restore_last_example()
			KEY_S:
				record_example()
		if KEY_0 <= keycode and keycode <= KEY_9 and keyboard_state == KeyboardState.RESTORE:
			# use order on keyboard
			var index = 9 if keycode == KEY_0 else keycode - KEY_1
			restore_slot(index)
		keyboard_state = next_keyboard_state

func _on_mode_selector_item_selected(index):
	var mode = [[true, false], [true, true], [false, true]][index]
	snapshot_enabled = mode[0]
	recording_enabled = mode[1]

func _on_save_example_checkbox_toggled(toggled_on):
	save_recorded_examples = toggled_on
