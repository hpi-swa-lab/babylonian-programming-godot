class_name Enemy extends CharacterBody2D

const SPEED = 200.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = -1
var is_dead = false

@onready var ground_areas: Array[Area2D] = [$LeftGround, $RightGround]

func _ready():
	$AnimatedSprite2D.play()
	for ground_area in ground_areas:
		ground_area.body_exited.connect(self.ground_area_check)

func _physics_process(delta):
	if is_dead:
		return

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	
	B.game_probe(velocity, self)

	move_and_slide()

	for collision_index in range(get_slide_collision_count()):
		var collision = get_slide_collision(collision_index)
		var collider = collision.get_collider()
		if collider is Player:
			collider.kill()
		else:
			var collision_direction = collision.get_normal().x
			if collision_direction != 0 and sign(collision_direction) != sign(direction):
				# hit a wall
				direction *= -1

func ground_area_check(_body):
	var direction_area = ground_areas[0 if direction < 0 else 1]
	if len(direction_area.get_overlapping_bodies()) == 0:
		direction *= -1

func kill():
	$AnimatedSprite2D.animation = "flat"
	direction = 0
	is_dead = true
	$CollisionShape2D.disabled = true
	await get_tree().create_timer(1).timeout
	queue_free()
