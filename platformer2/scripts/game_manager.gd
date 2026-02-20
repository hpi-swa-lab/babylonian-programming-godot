extends Node

var score: int = 0

@onready var score_label: Label = $ScoreLabel

func add_points(value: int) -> void:
	score += value
	score_label.text = "You collected " + str(score) + " coins."
