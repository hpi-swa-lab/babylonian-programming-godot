extends Node

const message_capture = "watch_in_game_ui"
const snapshot_path = "res://examples/1.snapshot"
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

##### CALLED FROM EDITOR

func editor_init():
	pass

func editor_ready():
	pass

func send_message_to(session_id: int, name: String, data: Array):
	debugger.send_message_to(session_id, message_capture + ":" + name, data)

func on_session_ready(session_id: int):
	send_message_to(session_id, "add_record_button", [])

func create_play_snapshot_button():
	var button = Button.new()
	button.text = "Play Snapshot"
	button.pressed.connect(self.play_snapshot)
	return button

func play_snapshot():
	var file = FileAccess.open(snapshot_path, FileAccess.READ)
	var snapshot_bytes = file.get_buffer(file.get_length())
	var snapshot = bytes_to_var_with_objects(snapshot_bytes)

##### CALLED FROM GAME

var snapshot: Snapshot

func game_init():
	EngineDebugger.register_message_capture(message_capture, self.on_message)
	EngineDebugger.send_message(message_capture + ":game_ready", [])

func game_ready():
	take_and_remember_snapshot()

func snapshot_target():
	return get_tree().current_scene

func set_snapshot_target(node: Node):
	get_tree().current_scene = node

func take_snapshot():
	return Snapshot.take(snapshot_target())

func take_and_remember_snapshot():
	snapshot = take_snapshot()

func _unhandled_input(event):
	if event is InputEventKey:
		if not event.pressed:
			return
		if event.keycode == KEY_R:
			var restored = snapshot.restore()
			Utils.full_replace_by(snapshot_target(), restored)
			set_snapshot_target(restored)
		if event.keycode == KEY_S:
			take_and_remember_snapshot()

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
	var current_snapshot = take_snapshot()
	var file = FileAccess.open(snapshot_path, FileAccess.WRITE)
	file.store_buffer(var_to_bytes_with_objects(current_snapshot))
