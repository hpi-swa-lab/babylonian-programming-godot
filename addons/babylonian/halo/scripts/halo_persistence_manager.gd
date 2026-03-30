class_name HaloPersistenceManager
extends Control

signal actions_changed

var _checkbox: CheckBox
var _config: HaloConfig

var _undo_stack: Array[HaloAction] = []
var _redo_stack: Array[HaloAction] = []

var _scene_root_id: int = -1


func init(config: HaloConfig) -> void:
	self._config = config


func _ready() -> void:
	self._checkbox = CheckBox.new()
	var ui_builder = HaloUIBuilder.new()
	var pos = self._config.ui_position if self._config else Vector2(5, 5)
	var canvas = ui_builder.style_static_saving_mode_checkbox(self._checkbox, pos)
	self.add_child(canvas)


func _input(event: InputEvent) -> void:
	if self._config == null:
		return
	if not event is InputEventKey:
		return

	if event.keycode == self._config.saving_key:
		self._checkbox.button_pressed = event.pressed
		self.get_viewport().set_input_as_handled()
		return

	if not event.pressed or event.echo:
		return

	if event.is_command_or_control_pressed():
		if event.keycode == self._config.undo_key:
			self.undo()
			self.get_viewport().set_input_as_handled()
		elif event.keycode == self._config.redo_key:
			self.redo()
			self.get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	# poll for scene reloads :(
	var scene = self.get_tree().current_scene
	if scene == null:
		return
	var id = scene.get_instance_id()
	if self._scene_root_id == -1:
		self._scene_root_id = id
	elif self._scene_root_id != id:
		self._scene_root_id = id
		self.call_deferred("_reapply_session_changes")


func set_property(node: Node, property: String, old_value: Variant = null) -> void:
	var new_value = node.get(property)
	self._push(SetPropertyAction.new(str(node.name), property, new_value, old_value))


func create_node(node: Node) -> void:
	self._push(CreateNodeAction.new(
		str(node.name), str(node.get_parent().get_path()),
		node.scene_file_path, node))


func delete_node(node: Node) -> void:
	var parent = node.get_parent()
	parent.remove_child(node)
	self._push(DeleteNodeAction.new(
		str(node.name), str(parent.get_path()),
		node.scene_file_path, node))


func _push(action: HaloAction) -> void:
	action.saved = self._checkbox.button_pressed
	self._undo_stack.push_back(action)
	self._redo_stack.clear()
	if action.saved:
		self._send(action.serialize(self.get_tree()))
	self.actions_changed.emit()


func undo() -> void:
	if self._undo_stack.is_empty():
		push_warning("Undo stack empty")
		return
	var action = self._undo_stack.pop_back()
	self._redo_stack.push_back(action)
	var inverse = action.inverse()
	if inverse == null:
		push_warning("No undo available for: " + action.summary())
		return
	inverse.apply(self.get_tree())
	if action.saved:
		self._send(inverse.serialize(self.get_tree()))
	self.actions_changed.emit()


func redo() -> void:
	if self._redo_stack.is_empty():
		push_warning("Redo stack empty")
		return
	var action = self._redo_stack.pop_back()
	self._undo_stack.push_back(action)
	action.apply(self.get_tree())
	if action.saved:
		self._send(action.serialize(self.get_tree()))
	self.actions_changed.emit()


func save_node(target_name: String) -> void:
	for action in self._undo_stack:
		# todo: handle already saved actions that would get overridden
		if not action.saved and action.node_name == target_name:
			action.saved = true
			self._send(action.serialize(self.get_tree()))
	self.actions_changed.emit()


func get_node_summary(target_name: String) -> String:
	var lines: Array[String] = []
	for action in self._undo_stack:
		if action.node_name != target_name:
			continue
		var text = action.summary()
		if text.is_empty():
			continue
		# mark unsaved changes with *
		text = ("* " if not action.saved else "  ") + text
		lines.append(text)
	if lines.is_empty():
		return "\n\nNo changes for this node"
	return "\n\n" + "\n".join(lines)


func _reapply_session_changes() -> void:
	for action in self._undo_stack:
		if action.saved:
			action.apply(self.get_tree())


func _send(msg: Array) -> void:
	if msg.size() == 2:
		EngineDebugger.send_message(msg[0], msg[1])
