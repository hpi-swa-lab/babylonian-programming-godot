extends RigidBody2D

var speed = 200
var angle = deg_to_rad(10)
var direction = Vector2.LEFT.rotated(angle)
var life_time = 5  # seconds

func _ready():
	self.apply_impulse(direction * speed)
	destruct_after_time()
	
func destruct_after_time():
	await get_tree().create_timer(self.life_time).timeout
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
	queue_free()
