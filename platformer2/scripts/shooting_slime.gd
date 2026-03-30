extends Node2D

@export var shoot_interval: float = 2.0

var projectile = preload("res://platformer2/scenes/projectile.tscn")
var time_since_shot: float = 0.0

func _ready():
	time_since_shot = shoot_interval

func _process(delta: float):
	time_since_shot += delta
	if time_since_shot >= shoot_interval:
		shoot()
		time_since_shot = 0.0

func shoot():
	var projectile_instance = projectile.instantiate()
	self.add_child(projectile_instance)
