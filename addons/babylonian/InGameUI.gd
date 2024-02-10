extends CanvasLayer

var examples: Examples

func _ready():
	if Engine.is_editor_hint():
		return
	examples = preload("res://addons/babylonian/examples.tscn").instantiate()
	add_child(examples)

func _process(delta):
	if Engine.is_editor_hint():
		return
	examples.recordings.process_recording_playback()
