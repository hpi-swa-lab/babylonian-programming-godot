extends Node
class_name Examples

var snapshots = Snapshots.new()
var recordings = Recordings.new()

var snapshot_enabled = true
var recording_enabled = true
var save_recorded_examples = false

var example_slots = []
var last_example_slot = -1

func _ready():
	for child in [snapshots, recordings]:
		add_child(child)

func create_example(snapshot, recording):
	return {
		"snapshot": snapshot,
		"recording": recording,
	}

func restore_example(example):
	var snapshot = example["snapshot"]
	var recording = example["recording"]
	if snapshot != null:
		snapshots.restore_snapshot(snapshot)
	if recording != null:
		recordings.playback_recording(recording)

func restore_slot(index):
	if index >= len(example_slots):
		return
	restore_example(example_slots[index])
	last_example_slot = index

func restore_last_example():
	restore_slot(last_example_slot)

func add_example_slot(example):
	example_slots.append(example)
	last_example_slot = len(example_slots) - 1

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
	if save_recorded_examples:
		save_example(example)
	add_example_slot(example)

func choose_example_path(mode: FileDialog.FileMode):
	var dialog = FileDialog.new()
	dialog.file_mode = mode
	dialog.root_subfolder = "res://examples"
	dialog.add_filter("*.json", "JSON")
	add_child(dialog)
	dialog.popup_centered_ratio(0.5)
	return await dialog.file_selected

func example_to_string(example):
	return JSON.stringify({
		"snapshot": example["snapshot"],
		"recording": recordings.recording_to_serializable(example["recording"]),
	})

func example_from_string(json):
	var example = JSON.parse_string(json)
	return {
		"snapshot": example["snapshot"],
		"recording": recordings.recording_from_serializable(example["recording"])
	}

func save_example(example):
	var path = await choose_example_path(FileDialog.FILE_MODE_SAVE_FILE)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(example_to_string(example))
	file.close()

func load_example():
	var path = await choose_example_path(FileDialog.FILE_MODE_OPEN_FILE)
	var file = FileAccess.open(path, FileAccess.READ)
	var json = file.get_as_text()
	var example = example_from_string(json)
	file.close()
	return example

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
