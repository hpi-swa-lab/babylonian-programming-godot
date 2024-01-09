extends CharacterBody2D
class_name Mario


const SPEED = 500.0
const JUMP_VELOCITY = -600.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var start_position = global_position

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
		velocity.x = B.watch(direction) * B.watch(SPEED)
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
				B.watch(Color.hex(0xcff00ff))
				
				collider.apply_force(force)
			
			if collider is Goomba and not collider.is_dead:
				if collision.get_normal().y < 0:
					collider.kill()
					velocity.y = JUMP_VELOCITY * 0.5
				else:
					self.kill()
	
	$Sprite.flip_h = velocity.x < 0
	$Sprite.speed_scale = velocity.x / 150
	if global_position.y > 1200:
		kill()

func kill():
	global_position = start_position
	velocity = Vector2.ZERO
