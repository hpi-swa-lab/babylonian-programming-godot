extends RigidBody2D

func thing(x: Variant):
	print(x)
	return x

var time = 0

func _process(delta):
	time += delta
	var viewport_rect = get_viewport_rect()
	if viewport_rect.end.y < global_position.y:
		position = viewport_rect.get_center()
		linear_velocity = Vector2.ZERO
		
	$Sprite.modulate = Color.from_hsv(B.watch(linear_velocity.length() / 1000), 1, 1)
	
	B.watch($Sprite.modulate)
