extends Node
class_name SequencerTrack

#track params
@export var track_settings:SequencerTrackSettings

#set by SequencerTrackSettings
var track_radius: int
var step_radius: int
var num_steps: int

#non-configured properties
var notes: Array[int] = []
var wrong_notes: Array[bool] = []
var active: bool = false
var cursor_step:int = -1
var angle_per_step: float
var last_step:int = -1

const CENTER_X:int = 512 #auto-sized based on viewport
const CENTER_Y:int = 300 #auto-sized based on viewport

func _init(settings: SequencerTrackSettings):
	update_track_settings(settings)
	notes.resize(num_steps)
	for i in notes.size():
		notes[i] = -1
	wrong_notes.resize(num_steps)


func update_track_settings(settings: SequencerTrackSettings):
	track_settings = settings
	track_radius = track_settings.track_radius
	step_radius = track_settings.step_radius
	num_steps = track_settings.num_steps
	angle_per_step = 360.0 / num_steps
	
