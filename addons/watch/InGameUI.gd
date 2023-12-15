extends Node

const message_capture = "watch_in_game_ui"
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
			full_replace_by(snapshot_target(), restored)
			set_snapshot_target(restored)
		if event.keycode == KEY_S:
			take_and_remember_snapshot()

func full_replace_by(original: Node, replacement: Node):
	var parent = original.get_parent()
	var index = original.get_index()
	parent.remove_child(original)
	parent.add_child(replacement)
	parent.move_child(replacement, index)

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
	root.add_child(button)

func set_owners(node: Node, owner: Node):
	node.scene_file_path = ""
	for child in node.get_children():
		child.owner = owner
		set_owners(child, owner)

func on_record():
	var root = get_tree().current_scene.duplicate(DUPLICATE_SIGNALS | DUPLICATE_GROUPS | DUPLICATE_SCRIPTS)
	set_owners(root, root)
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(root)
	if result != OK:
		push_error("recording the scene failed with error " + error_string(result))
		return
	result = ResourceSaver.save(packed_scene, "res://examples/1.tscn")
	if result != OK:
		push_error("saving the recorded scene failed with error " + error_string(result))
		return
