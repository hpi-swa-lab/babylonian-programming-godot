class_name Recordings extends Node

enum RecordMode {
	NONE,
	RECORD,
	PLAYBACK,
}

var recorded_events = []
var record_mode = RecordMode.NONE
var loop_playback = false
var next_played_event_index = 0
var recording_start_ticks = 0

signal looped_playback_ended

func current_ticks():
	return Time.get_ticks_usec()

func current_relative_ticks():
	return current_ticks() - recording_start_ticks

func _input(event: InputEvent):
	if record_mode != RecordMode.RECORD:
		return
	var ticks = current_relative_ticks()
	recorded_events.append([ticks, event])

func start_recording():
	record_mode = RecordMode.RECORD
	recorded_events = []
	recording_start_ticks = current_ticks()

func stop_recording():
	remove_last_mouse_click()
	record_mode = RecordMode.NONE

func remove_last_mouse_click():
	var to_remove = 2 # mouse down and mouse up
	for index in range(len(recorded_events) - 1, 0, -1):
		var event = recorded_events[index][1]
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			recorded_events.remove_at(index)
			to_remove -= 1
			if to_remove == 0:
				break

func playback_recording(events: Array, loop: bool):
	recorded_events = events
	loop_playback = loop
	record_mode = RecordMode.PLAYBACK
	next_played_event_index = 0
	recording_start_ticks = current_ticks()
	add_stop_playback_button()

func process_recording_playback():
	if record_mode != RecordMode.PLAYBACK:
		return
	var ticks = current_relative_ticks()
	var index = next_played_event_index
	while index < len(recorded_events):
		var recorded_event = recorded_events[index]
		var event_ticks = recorded_event[0] as int
		var event = recorded_event[1] as InputEvent
		if event_ticks > ticks:
			break
		Input.parse_input_event(event)
		index += 1
	next_played_event_index = index
	if next_played_event_index >= len(recorded_events):
		handle_playback_ended()

func handle_playback_ended():
	if loop_playback:
		looped_playback_ended.emit()
	else:
		stop_playback()

var stop_playback_button: Button

func add_stop_playback_button():
	if stop_playback_button != null:
		return
	stop_playback_button = Button.new()
	stop_playback_button.text = "Stop playback"
	stop_playback_button.pressed.connect(self.stop_playback)
	add_child(stop_playback_button)

func stop_playback():
	record_mode = RecordMode.NONE
	if stop_playback_button != null:
		stop_playback_button.queue_free()
		stop_playback_button = null

func do_recording():
	var stop_button = Button.new()
	stop_button.text = "Stop recording"
	# TODO: positioning
	add_child(stop_button)
	start_recording()
	await stop_button.pressed
	stop_recording()
	stop_button.queue_free()
	return recorded_events

func recording_to_serializable(events):
	if events == null:
		return null
	var serializable_recording = events.duplicate()
	for index in range(len(serializable_recording)):
		serializable_recording[index][1] = var_to_str(serializable_recording[index][1])
	return serializable_recording

func recording_from_serializable(serializable_events):
	if serializable_events == null:
		return null
	var events = serializable_events.duplicate()
	for index in range(len(events)):
		events[index][1] = str_to_var(events[index][1])
	return events
