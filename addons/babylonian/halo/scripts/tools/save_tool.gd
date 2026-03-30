class_name SaveTool
extends HaloTool

var _connected = false


func _init() -> void:
	self.name = "Save"
	self.description = "Save this node's changes to the editor"
	self.color = Color.GREEN
	self.icon = self.icon_from_atlas(3, 9)


func get_button() -> TextureButton:
	var button = super.get_button()
	if not self._connected:
		Halo.persistence.actions_changed.connect(self._update_tooltip)
		self._connected = true
	self._update_tooltip()
	return button


func start_interaction() -> void:
	self._button.modulate = Color.DARK_GREEN
	var target = Halo.get_target()
	if target:
		Halo.persistence.save_node(str(target.name))
	Halo.finish_previous_tool_interaction()


func finish_interaction() -> void:
	self._button.modulate = Color.GREEN


func _update_tooltip() -> void:
	if not self._button:
		return
	var target = Halo.get_target()
	if target:
		self._button.tooltip_text = self.name + "\n" + self.description + Halo.persistence.get_node_summary(str(target.name))
	else:
		self._button.tooltip_text = self.name + "\n" + self.description
