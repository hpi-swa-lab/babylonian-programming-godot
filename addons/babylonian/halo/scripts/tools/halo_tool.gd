class_name HaloTool extends RefCounted

const ATLAS: Texture2D = preload("res://addons/babylonian/halo/assets/ui_0.png")
const ICON_SIZE: int = 50

var _button: TextureButton = null

# override in tool
var name: String = ""
var description: String = ""
var color: Color = Color.WHITE
var icon: Texture2D = icon_from_atlas(1, 7)
var callback: Callable = Callable()
var filter_type: Variant = null  # Variant.Type

# overide methods in tool
func start_interaction() -> void:
	pass


func interact(delta: float) -> void:
	pass

	
func finish_interaction() -> void:
	pass


func _on_click() -> void:
	Halo.finish_previous_tool_interaction()
	Halo.set_active_tool(self)
	self._button.release_focus()  # avoid button presses with space bar
	if self.callback.is_valid():
		self.callback.call()
	else:
		self.start_interaction()


func get_button() -> TextureButton:
	if self._button == null:
		self._button = TextureButton.new()
		self._button.texture_normal = self.icon
		self._button.modulate = self.color
		self._button.size = Vector2(50, 50)
		self._button.scale = Vector2(0.25, 0.25)
		self._button.z_index = 128
		_button.tooltip_text = self.name + "\n" + self.description
		self._button.button_down.connect(self._on_click)
	return self._button


static func icon_from_atlas(x: int, y: int) -> Texture2D:
	var texture = AtlasTexture.new()
	texture.atlas = ATLAS
	texture.region = Rect2(Vector2(ICON_SIZE * x, ICON_SIZE * y), Vector2(ICON_SIZE, ICON_SIZE))
	return texture
