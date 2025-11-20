class_name HaloTool extends RefCounted

const ATLAS: Texture2D = preload("res://addons/babylonian/halo/assets/ui_0.png")
const ICON_SIZE: int = 50

var target: CanvasItem = null
var is_active: bool = false

# override in tool
var name: String = "Tool"
var color: Color = Color.WHITE
var icon: Texture2D = icon_from_atlas(1, 7)

static func icon_from_atlas(x: int, y: int) -> Texture2D:
	var texture = AtlasTexture.new()
	texture.atlas = ATLAS
	texture.region = Rect2(Vector2(ICON_SIZE * x, ICON_SIZE * y), Vector2(ICON_SIZE, ICON_SIZE))
	return texture

func on_click(target: CanvasItem) -> void:
	self.target = target
	is_active = not is_active
	if is_active:
		activate()
	else:
		deactivate()

func cleanup() -> void:
	is_active = false
	target = null


# overide methods in tool
func activate() -> void:
	pass
	
func deactivate() -> void:
	pass

func process(delta: float) -> void:
	pass
	
