extends Node2D

var t = 0

func _process(delta):
	t += delta
	
	B.watch(delta)
	
	
	B.watch(Color.BLUE.lerp(Color.ORANGE, fmod(t, 1.0)))
	
	B.watch(Vector2.from_angle(sin(t * 5)))
	
	B.watch(sin(t * 10))
	
	
	B.watch(str(delta))
