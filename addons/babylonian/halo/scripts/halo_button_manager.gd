class_name HaloButtonManager extends RefCounted

var _buttons: Dictionary[int, TextureButton] = {}
var _node_types: Dictionary = {}
var _next_button_id: int = 0

func add_button(texture: Texture2D, callback: Callable, node_types: Array[String] = [], color_modulation: Color = Color.WHITE) -> int:
	var button_signal_handler = func() -> void:
		callback.call(self.halo_target)
	
	var button: TextureButton = TextureButton.new()
	button.texture_normal = texture
	button.modulate = color_modulation
	button.size = Vector2(50, 50)
	button.scale = Vector2(0.2, 0.2)
	button.z_index = 128
	button.pressed.connect(button_signal_handler)
	
	self._buttons[self._next_button_id] = button
	self._node_types[self._next_button_id] = node_types
	self._next_button_id += 1
	return self._next_button_id - 1
	
func remove_button(button_id: int) -> void:
	self._buttons.erase(button_id)
	self._node_types.erase(button_id)
	
func get_buttons(target: CanvasItem) -> Array[TextureButton]:
	var halo_buttons: Array[TextureButton] = []
	for button_id in self._buttons:
		var button: TextureButton = self._buttons[button_id]
		var types: Array[String] = self._node_types[button_id]
		
		if types.size() == 0:
			halo_buttons.append(button)
			
		else:
			for type in types:
				if target.get_class() == type:
					halo_buttons.append(button)
					break
					
	return halo_buttons
