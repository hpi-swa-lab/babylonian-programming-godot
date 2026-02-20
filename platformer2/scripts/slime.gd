class_name Slime extends Node2D


const SPEED: int = 60

var _direction: int = 1
var _is_moving: bool = true

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


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
