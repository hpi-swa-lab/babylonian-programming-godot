extends Camera2D

@export var target: Node2D

func _process(delta):
	global_position = lerp(global_position, target.global_position, 0.05)
