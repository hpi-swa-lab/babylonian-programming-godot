class_name HaloButtonManager extends RefCounted

var _textures: Dictionary = {}
var _callbacks: Dictionary = {}
var _node_types: Dictionary = {}
var _color_modulations: Dictionary = {}

var _next_button_id: int = 0
var _dispatcher: HaloDispatcher

func init(dispatcher: HaloDispatcher) -> HaloButtonManager:
	self._dispatcher = dispatcher
	return self

func add_button(texture: Texture2D, callback: Callable, node_types: Array[String] = [], color_modulation: Color = Color.WHITE) -> int:
	self._textures[self._next_button_id] = texture
	self._callbacks[self._next_button_id] = callback
	self._node_types[self._next_button_id] = node_types
	self._color_modulations[self._next_button_id] = color_modulation
	
	self._next_button_id += 1
	return self._next_button_id - 1

func remove_button(button_id: int) -> void:
	self._textures.erase(button_id)
	self._callbacks.erase(button_id)
	self._node_types.erase(button_id)
	self._color_modulations.erase(button_id)

func get_buttons(target: CanvasItem) -> Array[TextureButton]:
	var halo_buttons: Array[TextureButton] = []
	for button_id in self._next_button_id:
		var types: Array[String] = self._node_types[button_id]
		
		if types.size() == 0:
			halo_buttons.append(self._build_button(button_id))
			
		else:
			for t in types:
				if self._is_type_of(target, t):
					halo_buttons.append(self._build_button(button_id))
					break
					
	return halo_buttons
	
func _build_button(button_id: int) -> TextureButton:
	var texture: Texture2D = self._textures[button_id]
	var callback: Callable = self._callbacks[button_id]
	var node_types: Array[String] = self._node_types[button_id]
	var color_modulation: Color = self._color_modulations[button_id]
	
	var button_signal_handler = func() -> void:
		callback.call(self._dispatcher.halo_target)
	
	var button: TextureButton = TextureButton.new()
	button.texture_normal = texture
	button.modulate = color_modulation
	button.size = Vector2(50, 50)
	button.scale = Vector2(0.2, 0.2)
	button.z_index = 128
	button.pressed.connect(button_signal_handler)
	
	return button
	
func _is_type_of(object: Node, type_name: String) -> bool:
	if object.get_class() == type_name:
		return true
	
	var script = object.get_script()
	if script and script.get_global_name() == type_name:
		return true
	
	return false
