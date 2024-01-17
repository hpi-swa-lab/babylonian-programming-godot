extends Node
class_name Recordings

enum RecordMode {
	NONE,
	RECORD,
	PLAYBACK,
}

var recorded_events = []
var record_mode = RecordMode.NONE
var next_played_event_index = 0
var recording_start_ticks = 0

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
	record_mode = RecordMode.NONE

func playback_recording(events: Array):
	recorded_events = events
	record_mode = RecordMode.PLAYBACK
	next_played_event_index = 0
	recording_start_ticks = current_ticks()

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

func do_recording():
	var stop_button = Button.new()
	stop_button.text = "Stop recording"
	# TODO: positioning
	add_child(stop_button)
	start_recording()
	await stop_button.pressed
	stop_recording()
	return recorded_events

func recording_to_serializable(events):
	var serializable_recording = events.duplicate()
	for index in range(len(serializable_recording)):
		serializable_recording[index][1] = var_to_str(serializable_recording[index][1])
	return serializable_recording

func recording_from_serializable(serializable_events):
	var events = serializable_events.duplicate()
	for index in range(len(events)):
		events[index][1] = str_to_var(events[index][1])
	return events
