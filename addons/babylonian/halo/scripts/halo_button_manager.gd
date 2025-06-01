class_name HaloButtonManager extends RefCounted

var buttons: Dictionary[int, TextureButton] = {}
var node_types: Dictionary = {}
var next_button_id: int = 0

func add_button(texture: Texture2D, callback: Callable, NodeTypes: Array[String] = [], color_modulation: Color = Color.WHITE) -> int:
	var button_signal_handler = func() -> void:
		callback.call(self.halo_target)
	
	var button: TextureButton = TextureButton.new()
	button.texture_normal = texture
	button.modulate = color_modulation
	button.size = Vector2(50, 50)
	button.scale = Vector2(0.2, 0.2)
	button.z_index = 128
	button.pressed.connect(button_signal_handler)
	
	self.buttons[self.next_button_id] = button
	self.node_types[self.next_button_id] = node_types
	self.next_button_id += 1
	return self.next_button_id - 1
	
func remove_button(button_id: int) -> void:
	self.buttons.erase(button_id)
	self.node_types.erase(button_id)
	
func get_buttons(target: CanvasItem) -> Array[TextureButton]:
	var halo_buttons: Array[TextureButton] = []
	for button_id in self.buttons:
		var button: TextureButton = self.buttons[button_id]
		var types: Array[String] = self.node_types[button_id]
		
		if types.size() == 0:
			halo_buttons.append(button)
			
		else:
			for type in types:
				if target.get_class() == type:
					halo_buttons.append(button)
					break
					
	return halo_buttons
