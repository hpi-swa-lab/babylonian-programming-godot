extends CharacterBody2D


const SPEED = 500.0
const JUMP_VELOCITY = -600.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$Sprite.play()

func _physics_process(delta):
	# Add the gravity.
	B.watch(abs(velocity.x))
	
	
	
	if not is_on_floor():
		velocity.y += gravity * delta
		$Sprite.animation = "jump"
	elif abs(velocity.x) > 5:
		$Sprite.animation = "walk"
	else:
		$Sprite.animation = "stand"
	
	B.watch(velocity)
	
	B.watch($Sprite.animation)

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.2)
		
	B.watch(Color.hex(0x16622ff))

	if move_and_slide():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider is RigidBody2D:
				var force = (2 * Vector2.UP - collision.get_normal()) * velocity.length()
				B.watch(collider.name)
				
				B.watch(force)
				
				B.watch(str(force.length()))
				B.watch(collider.get_node("Sprite").modulate)
				
				collider.apply_force(force)
	
	$Sprite.flip_h = velocity.x < 0
	$Sprite.speed_scale = velocity.x / 150
