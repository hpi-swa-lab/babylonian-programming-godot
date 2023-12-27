extends Node

const message_capture = "watch_in_game_ui"
const snapshot_path = "res://snapshots/1.json"
const recording_path = "res://recordings/1.json"
var debugger

func _init():
	if Engine.is_editor_hint():
		editor_init()
	else:
		game_init()

func _ready():
	if Engine.is_editor_hint():
		editor_ready()
	else:
		game_ready()

func _process(delta):
	if Engine.is_editor_hint():
		editor_process(delta)
	else:
		game_process(delta)

##### CALLED FROM EDITOR

func editor_init():
	pass

func editor_ready():
	pass

func editor_process(delta):
	pass

func send_message_to(session_id: int, name: String, data: Array):
	debugger.send_message_to(session_id, message_capture + ":" + name, data)

func on_session_ready(session_id: int):
	send_message_to(session_id, "add_record_button", [])

##### CALLED FROM GAME

var snapshot: String

func game_init():
	EngineDebugger.register_message_capture(message_capture, self.on_message)
	EngineDebugger.send_message(message_capture + ":game_ready", [])

func game_ready():
	take_and_remember_snapshot()
	read_saved_recording()

func game_process(delta):
	playback_recording()

func snapshot_target():
	return get_tree().current_scene

func set_snapshot_target(node: Node):
	get_tree().current_scene = node

func take_snapshot():
	return Serializer.serialize_to_json(snapshot_target())

func take_and_remember_snapshot():
	snapshot = take_snapshot()

func _unhandled_input(event):
	if event is InputEventKey:
		if not event.pressed:
			return
		if event.keycode == KEY_R:
			var restored = Deserializer.deserialize_json(snapshot)
			Utils.full_replace_by(snapshot_target(), restored)
			set_snapshot_target(restored)
		if event.keycode == KEY_S:
			take_and_remember_snapshot()

enum RecordMode {
	NONE,
	RECORD,
	PLAYBACK,
}

var recorded_events = []
var record_mode = RecordMode.RECORD

func _input(event: InputEvent):
	if record_mode != RecordMode.RECORD:
		return
	var ticks = Time.get_ticks_usec()
	recorded_events.append([ticks, event])

func start_playback_recording(events: Array):
	recorded_events = events
	record_mode = RecordMode.PLAYBACK

func read_saved_recording():
	if not FileAccess.file_exists(recording_path):
		return
	var file = FileAccess.open(recording_path, FileAccess.READ)
	var json = file.get_as_text()
	var recording = JSON.parse_string(json)
	for index in range(len(recording)):
		recording[index][1] = str_to_var(recording[index][1])
	file.close()
	start_playback_recording(recording)

var next_played_event_index = 0

func playback_recording():
	if record_mode != RecordMode.PLAYBACK:
		return
	var current_ticks = Time.get_ticks_usec()
	var index = next_played_event_index
	while index < len(recorded_events):
		var recorded_event = recorded_events[index]
		var event_ticks = recorded_event[0] as int
		var event = recorded_event[1] as InputEvent
		if event_ticks > current_ticks:
			break
		Input.parse_input_event(event)
		index += 1
	next_played_event_index = index

func on_message(name: String, data: Array):
	match name:
		"add_record_button":
			add_record_button()
			return true
	return false

func add_record_button():
	var root = get_node("/root")
	var button = Button.new()
	button.text = "⏺"
	button.pressed.connect(self.on_record)
	root.add_child.call_deferred(button)

func set_owners(node: Node, owner: Node):
	node.scene_file_path = ""
	for child in node.get_children():
		child.owner = owner
		set_owners(child, owner)

func on_record():
	if record_mode == RecordMode.PLAYBACK:
		return
	var current_snapshot = take_snapshot()
	var file = FileAccess.open(snapshot_path, FileAccess.WRITE)
	file.store_string(current_snapshot)
	file.close()
	var serialized_recording = recorded_events.duplicate()
	for index in range(len(serialized_recording)):
		serialized_recording[index][1] = var_to_str(serialized_recording[index][1])
	file = FileAccess.open(recording_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(recorded_events))
	file.close()
