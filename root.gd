extends Node2D

var t = 0

func _process(delta):
	B.watch(delta)
	
	t += delta
	
	B.watch(Color.BLUE.lerp(Color.ORANGE, fmod(t, 1.0)))
	
	B.watch(Vector2.from_angle(sin(t * 5)))
	
	B.watch(delta * 10)
	
	B.watch(3)
