extends Node

const message_capture = "watch_in_game_ui"
var debugger

func _init():
	if not Engine.is_editor_hint():
		EngineDebugger.register_message_capture(message_capture, self.on_message)
		EngineDebugger.send_message(message_capture + ":game_ready", [])

##### CALLED FROM EDITOR

func send_message_to(session_id: int, name: String, data: Array):
	debugger.send_message_to(session_id, message_capture + ":" + name, data)

func on_session_ready(session_id: int):
	send_message_to(session_id, "add_record_button", [])

##### CALLED FROM GAME

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
