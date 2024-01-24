extends CanvasLayer

var debugger

var examples: Examples

func _init():
	if Engine.is_editor_hint():
		editor_init()
	else:
		game_init()

func _ready():
	if Engine.is_editor_hint():
		editor_ready()
	else:
		game_ready()

func _process(delta):
	if Engine.is_editor_hint():
		editor_process(delta)
	else:
		game_process(delta)

##### CALLED FROM EDITOR

func editor_init():
	pass

func editor_ready():
	pass

func editor_process(delta):
	pass

##### CALLED FROM GAME

func game_init():
	pass

func game_ready():
	examples = preload("res://addons/watch/examples.tscn").instantiate()
	add_child(examples)

func game_process(delta):
	examples.recordings.process_recording_playback()
