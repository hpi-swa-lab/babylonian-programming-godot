extends Node2D

func _process(delta):
	B.watch(delta)
	
	B.watch(Color.AQUA)
	
	B.watch(delta * 10)
