class_name Slime extends Node2D


const SPEED: int = 60

var _direction: int = 1
var _is_moving: bool = true
static var _initialized: bool = false

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _add_button() -> void:
	var button_handler = func(target: CanvasItem) -> void:
		target._is_moving = not target._is_moving
		
	var atlas: Texture2D = load("res://addons/babylonian/halo/assets/ui_0.png")
	var region: Rect2 = Rect2( Vector2(100, 450), Vector2(50, 50) )
	var texture: Texture2D = AtlasTexture.new()
	texture.atlas = atlas
	texture.region = region
		
	#HaloDispatcher.button_manager.add_button(
		#texture, 
		#button_handler,
		#["Slime"],
		#Color.ORANGE
	#)
	
	Slime._initialized = true

func _ready() -> void:
	if not Slime._initialized:
		self._add_button()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self._is_moving:
		if ray_cast_right.is_colliding():
			_direction = -1
			animated_sprite.flip_h = true
		if ray_cast_left.is_colliding():
			_direction = 1
			animated_sprite.flip_h = false
			
		position.x += _direction * SPEED * delta
