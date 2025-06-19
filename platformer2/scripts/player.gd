extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var gravity: Vector2

var slowmo: bool = false


func _physics_process(delta: float) -> void:
	# Add the gravity.     
	gravity = get_gravity()
	
	if Input.is_action_just_pressed("slowmo"):
		slowmo = true
	if Input.is_action_just_released("slowmo"):
		slowmo = false
		
	if slowmo and   velocity.y > 0: 
		gravity *= 0.1
	
	if not is_on_floor():
		velocity += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction: -1, 0, 1
	var direction := Input.get_axis("move_left", "move_right")
	
	# Flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		if slowmo:
			animated_sprite.play("roll")
		else:
			animated_sprite.play("jump")
			
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
