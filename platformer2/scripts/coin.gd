extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var game_manager: Node

#func _ready():
	#game_manager = $"../../GameManager"

func find_game_manager(node):
	if node.name == "GameManager":
		return node
	for child in node.get_children():
		var result = find_game_manager(child)
		if result:
			return result
	return null

func _ready():
	game_manager = find_game_manager(get_tree().get_root())

func _on_body_entered(body: Node2D) -> void:
	game_manager.add_point()
	animation_player.play("pickup")
