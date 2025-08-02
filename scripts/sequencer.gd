extends Node2D

# Constants
const CENTER_X: int     = 512  # Will be adjusted based on viewport
const CENTER_Y: int     = 300  # Will be adjusted based on viewport

@export var tracks: Array[SequencerTrack] = []

# Playback variables
@export var bpm: float              = 120.0
var steps_per_second: float = 0
# Sequencer state
var playhead_angle: float   = 0.0
var playing: bool     = true
var notes_hidden: bool = false
var last_step: int    = -1
var controls_locked: bool = true
#@onready var audio_manager:AudioManager = $AudioManager
@onready var instr_1_polyphonic_audio_player: AudioStreamPlayer2D = $instr1_PolyphonicAudioPlayer
@onready var instr_2_polyphonic_audio_player: AudioStreamPlayer2D = $instr2_PolyphonicAudioPlayer


signal pattern_complete
signal check_requested
signal play_goal_requested
# Audio variables
@onready var audio_player = AudioStreamPlayer.new()

var audio_generator: AudioStreamGenerator
var audio_playback: AudioStreamGeneratorPlayback
const SAMPLE_RATE: int = 22050 #44100
const TAU_FLOAT: float = TAU  # For our sine wave calculation
const A4_FREQ: float = 440.0  # A4 note frequency (MIDI note 69)
const NOTE_COLORS: Dictionary = {
									0: Color(0.5882353, 0.2, 1.0), # Purple (Root note)
									1: Color(0.28627452, 0.20784314, 0.9843137), # Dark Purple/Blue
									2: Color(0.30980393, 0.5568628, 1.0), # Periwinkle
									3: Color(0.2, 1.0, 0.8117647), # Teal
									4: Color(0.2, 1.0, 0.2), # Green
									5: Color(1.0, 1.0, 0.2), # Yellow
									6: Color(1.0, 0.5, 0.2), # Orange
									7: Color(1.0, 0.2, 0.2), # Red
								}

func _get_note_color(track:SequencerTrack, note_index: int) -> Color:
	if notes_hidden:
		return Color.LIGHT_GRAY
	elif track.notes[note_index] >= 0:
		if note_index == last_step && playing:
			return Color.WHITE
		# Get the scale degree (0-7 for an 8-note scale)
		var scale_degree: int = track.notes[note_index] % 8
		return NOTE_COLORS.get(scale_degree, Color.WHITE)  # White as fallback color
	return Color.DARK_GRAY

func setup_tracks(level: PuzzleLevel):
	tracks.clear()
	tracks.resize(level.track_settings.size())
	for i in level.track_settings.size():
		var settings = level.track_settings[i]
		print(level.track_settings.size())
		print(level.track_settings[i].goal_pattern.size())
		tracks[i] = SequencerTrack.new(level.track_settings[i])
	tracks[0].active = true
	steps_per_second = (bpm / 60)# * tracks[0].num_steps
	
func _ready() -> void:
	clear_pattern()
	stop()
	# Center position should be based on viewport size
	var viewport_size: Rect2 = get_viewport_rect()
	position = Vector2(viewport_size.size.x/2, viewport_size.size.y/2)

func _process(delta):
	if playing:
		# Update playhead (changed negative to positive for clockwise rotation)
		playhead_angle += steps_per_second * tracks[0].angle_per_step * delta
		playhead_angle = fmod(playhead_angle, 360.0)
		# Check if we hit a new step
		for i in range(tracks.size()):
			var current_step: int = int(playhead_angle / tracks[i].angle_per_step)
			if current_step != tracks[i].last_step:
				if (current_step == 0 && tracks[i].last_step == tracks[i].num_steps - 1):
					pattern_complete.emit()
				if tracks[i].notes[current_step] != -1:
					play_sample(i, tracks[i].notes[current_step])
				tracks[i].last_step = current_step
		
	queue_redraw()

func play_sample(track_index:int, note_index:int):
	prints("playing - track: ", track_index, ", sample: ", note_index)
	var sample_name = str(track_index) + "_" + str(note_index)
	match track_index:
		0:
			instr_1_polyphonic_audio_player.play_sound_effect_from_library(sample_name)
		1:
			instr_2_polyphonic_audio_player.play_sound_effect_from_library(sample_name)


func draw_wrong_note_indicator(pos):
	var indicator_length = 25
	var bottom_left = Vector2(pos.x - indicator_length/2, pos.y - indicator_length/2)
	var top_right = Vector2(pos.x + indicator_length/2, pos.y + indicator_length/2)
	draw_line(bottom_left, top_right, Color.BLACK, 5)


func draw_track(track:SequencerTrack):
	# Draw track circle
	draw_arc(Vector2.ZERO, track.track_radius, 0, TAU, 32, Color.WHITE)
	
	# Draw step positions
	for i in range(track.num_steps):
		var angle: float = deg_to_rad(i * track.angle_per_step)
		var pos: Vector2 = Vector2(
							   cos(angle) * track.track_radius,
							   sin(angle) * track.track_radius
						   )

		var color: Color = Color.DARK_GRAY
		color = _get_note_color(track, i)
		draw_circle(pos, track.step_radius, color)
		if track.wrong_notes[i]:
			draw_wrong_note_indicator(pos)
		
		# Draw cursor
		if !controls_locked && track.active:
			#might want to revist this for tighter controls or abandon if going for mouse controls
			if track.cursor_step >= track.num_steps:
				track.cursor_step = track.num_steps - 1
			
			var cursor_angle: float = deg_to_rad(track.cursor_step * track.angle_per_step)
			var cursor_pos: Vector2 = Vector2(
										  cos(cursor_angle) * track.track_radius,
										  sin(cursor_angle) * track.track_radius
									  )
			draw_circle(cursor_pos, 8, Color.TRANSPARENT)
			draw_arc(cursor_pos, track.step_radius + (track.step_radius * 0.25), 0, TAU, track.step_radius*2, Color.RED)


func _draw():
	if tracks.size() > 0:
		# Draw center dot
		draw_circle(Vector2.ZERO, 4, Color.WHITE)
		
		for i in range(tracks.size()):
			draw_track(tracks[i])

		# Draw playhead
		var playhead_rad: float   = deg_to_rad(playhead_angle)
		var playhead_end: Vector2 = Vector2(
										cos(playhead_rad) * (tracks[0].track_radius + 20),
										sin(playhead_rad) * (tracks[0].track_radius + 20)
									)
		draw_line(Vector2.ZERO, playhead_end, Color.YELLOW)


func change_track(direction:int):
	var active_track_index = -1
	var cursor_step = 0
	for i in range(tracks.size()):
		if tracks[i].active:
			active_track_index = i
			cursor_step = tracks[i].cursor_step
		tracks[i].active = false
	var new_active_track_index = (active_track_index + direction) % tracks.size()
	tracks[new_active_track_index].active = true
	var new_cursor_step = (float(cursor_step) / float(tracks[active_track_index].num_steps)) * float(tracks[new_active_track_index].num_steps)
	tracks[new_active_track_index].cursor_step = new_cursor_step


func cursor_move(steps:int):
	for i in range(tracks.size()):
		if tracks[i].active:
			if steps > 0:
				tracks[i].cursor_step = (tracks[i].cursor_step + steps) % tracks[i].num_steps
			else:
				tracks[i].cursor_step = (tracks[i].cursor_step - 1 +  tracks[i].num_steps) % tracks[i].num_steps


func change_note_pitch(steps:int):
	for i in range(tracks.size()):
		if tracks[i].active:
			if(steps > 0):
				tracks[i].notes[tracks[i].cursor_step] = min(tracks[i].notes[tracks[i].cursor_step] + steps, NOTE_COLORS.size() - 1)
			else:
				tracks[i].notes[tracks[i].cursor_step] = max(tracks[i].notes[tracks[i].cursor_step] + steps, -1)


func set_note_active():
	for i in range(tracks.size()):
		if tracks[i].active:
			if (tracks[i].notes[tracks[i].cursor_step] >= 0):
				tracks[i].notes[tracks[i].cursor_step] = -1
			else:
				tracks[i].notes[tracks[i].cursor_step] = 0


func _unhandled_input(event):
	if !controls_locked && event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_LEFT:
					cursor_move(-1)
				KEY_RIGHT:
					cursor_move(1)
				KEY_SHIFT:
					change_track(1)
				KEY_UP:
					change_note_pitch(1)
				KEY_DOWN:
					change_note_pitch(-1)
				KEY_Z:
					set_note_active()
				KEY_X:
					if (playing):
						pause()
					else:
						play()
				KEY_C:
					stop()
				KEY_A:
					play_goal_requested.emit()
				KEY_S:
					check_requested.emit()


func get_current_pattern():
	var pattern = []
	pattern.resize(tracks.size())
	for i in range(tracks.size()):
		pattern[i] = tracks[i].notes
	return pattern


func clear_pattern():
	for i in range(tracks.size()):
		for j in range(tracks[i].num_steps):
			tracks[i].notes[j] = -1


func set_pattern(new_pattern):
	for i in range(tracks.size()):
		tracks[i].notes.resize(new_pattern[i].size())
		tracks[i].notes = new_pattern[i]


func stop():
	playing = false
	last_step = -1
	playhead_angle = 0


func play():
	playing = true


func pause():
	playing = false


func hide_notes():
	notes_hidden = true


func show_notes():
	notes_hidden = false


func set_wrong_notes(new_wrong_notes) -> void:
		for i in range(new_wrong_notes.size()):
			tracks[i].wrong_notes.resize(new_wrong_notes[i].size())
			for j in range(new_wrong_notes[i].size()):
				tracks[i].wrong_notes[j] = new_wrong_notes[i][j]


func clear_wrong_notes() -> void:
	var cleared_wrong_notes: Array[bool] = []
	for i in range(tracks.size()):
		tracks[i].notes
		cleared_wrong_notes.resize(tracks[i].num_steps)
		tracks[i].wrong_notes = cleared_wrong_notes


func lock_controls(locked: bool):
	controls_locked = locked


func win_state():
	clear_wrong_notes()
	lock_controls(true)


func lose_state():
	lock_controls(true)


func play_state():
	playing = true
	#lock_controls(false)
