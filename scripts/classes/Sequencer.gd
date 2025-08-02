extends Node2D

# Constants
const TRACK_RADIUS: int = 200
const STEP_RADIUS: int = 20
@export var NUM_STEPS: int    = 16
const CENTER_X: int     = 512  # Will be adjusted based on viewport
const CENTER_Y: int     = 300  # Will be adjusted based on viewport
# Playback variables
@export var bpm: float              = 120.0
@export var note_scale: Array[Variant] = [62, 64, 66, 67, 69, 71, 73, 74]  # MIDI note numbers
@export var note_names: Array[Variant] = ["D", "E", "F#", "G", "A", "B", "C#", "D"]
var notes: Array[int] = []
var steps_per_second: float = (bpm / 60.0) * 4.0  # 16th notes
var angle_per_step: float   = 360.0 / NUM_STEPS
# Sequencer state
var playhead_angle: float   = 0.0
var cursor_step: int  = 0
var wrong_notes: Array[bool] = []
var playing: bool     = true
var notes_hidden: bool = false
var last_step: int    = -1
# Musical scale (D major)
var controls_locked: bool = true

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


func _get_note_color(note_index: int) -> Color:
	if notes_hidden:
		return Color.LIGHT_GRAY
	elif notes[note_index] >= 0:
		if note_index == last_step && playing:
			return Color.WHITE
		# Get the scale degree (0-7 for an 8-note scale)
		var scale_degree: int = notes[note_index] % 8
		return NOTE_COLORS.get(scale_degree, Color.WHITE)  # White as fallback color
	return Color.DARK_GRAY


func _ready() -> void:
	# Initialize arrays
	notes.resize(NUM_STEPS)
	wrong_notes.resize(NUM_STEPS)

	clear_pattern()
	stop()
	# Center position should be based on viewport size
	var viewport_size: Rect2 = get_viewport_rect()
	position = Vector2(viewport_size.size.x/2, viewport_size.size.y/2)

	# Initialize audio
	setup_audio()
	add_child(audio_player)

	# Wait for the next frame to ensure audio_player is ready
	await setup_audio()

	# Wait for the next frame to ensure audio_player is ready
	await get_tree().process_frame

	audio_playback = audio_player.get_stream_playback()
	fill_buffer_with_silence()


func setup_audio():
	audio_generator = AudioStreamGenerator.new()
	audio_generator.buffer_length = .1 # * 100 = ms
	audio_generator.mix_rate = SAMPLE_RATE
	audio_generator.mix_rate_mode = AudioStreamGenerator.MIX_RATE_CUSTOM

	audio_player.stream = audio_generator
	audio_player.play()

	# Wait for the next frame to ensure audio_player is ready
	await get_tree().process_frame

	audio_playback = audio_player.get_stream_playback()
	fill_buffer_with_silence()


func fill_buffer_with_silence():
	# Fill the buffer with zeros (silence) for both channels
	while audio_playback.can_push_buffer(1):
		audio_playback.push_buffer(PackedVector2Array([Vector2(0.0, 0.0)]))


func midi_to_freq(midi_note: int) -> float:
	# Convert MIDI note number to frequency
	return A4_FREQ * pow(2.0, (midi_note - 69.0) / 12.0)


func generate_tone(frequency: float, duration: float, volume: float = 0.5):
	var sample_count: int = int(duration * SAMPLE_RATE)
	var increment: float  = frequency / SAMPLE_RATE
	var phase: float      = 0.0

	var attack_time: float   = 0.01
	var release_time: float  = 0.05
	var attack_samples: int  = int(attack_time * SAMPLE_RATE)
	var release_samples: int = int(release_time * SAMPLE_RATE)

	for i in range(sample_count):
		if audio_playback.can_push_buffer(1):
			var envelope: float = 1.0

			if i < attack_samples:
				envelope = float(i) / attack_samples
			elif i > sample_count - release_samples:
				envelope = float(sample_count - i) / release_samples

			var sample: float = sin(phase * TAU_FLOAT) * volume * envelope
			# Same sample for both channels (mono to stereo)
			audio_playback.push_buffer(PackedVector2Array([Vector2(sample, sample)]))

			phase = fmod(phase + increment, 1.0)


func _process(delta):
	if playing:
		# Update playhead (changed negative to positive for clockwise rotation)
		playhead_angle += steps_per_second * angle_per_step * delta
		playhead_angle = fmod(playhead_angle, 360.0)

		# Check if we hit a new step
		var current_step: int = int(playhead_angle / angle_per_step)
		if current_step != last_step:
			if (current_step == 0 && last_step == NUM_STEPS - 1):
				pattern_complete.emit()
			if notes[current_step] != -1:
				play_note(note_scale[notes[current_step]])
			last_step = current_step

	queue_redraw()

func draw_wrong_note_indicator(pos):
	var indicator_length = 25
	var bottom_left = Vector2(pos.x - indicator_length/2, pos.y - indicator_length/2)
	var top_right = Vector2(pos.x + indicator_length/2, pos.y + indicator_length/2)
	draw_line(bottom_left, top_right, Color.BLACK, 5)

func _draw():
	# Draw center dot
	draw_circle(Vector2.ZERO, 4, Color.WHITE)

	# Draw track circle
	draw_arc(Vector2.ZERO, TRACK_RADIUS, 0, TAU, 32, Color.WHITE)

	# Draw step positions
	for i in range(NUM_STEPS):
		var angle: float = deg_to_rad(i * angle_per_step)
		var pos: Vector2 = Vector2(
							   cos(angle) * TRACK_RADIUS,
							   sin(angle) * TRACK_RADIUS
						   )

		var color: Color = Color.DARK_GRAY
		color = _get_note_color(i)
		draw_circle(pos, STEP_RADIUS, color)
		if wrong_notes[i]:
			draw_wrong_note_indicator(pos)

	# Draw cursor
	if !controls_locked:
		var cursor_angle: float = deg_to_rad(cursor_step * angle_per_step)
		var cursor_pos: Vector2 = Vector2(
									  cos(cursor_angle) * TRACK_RADIUS,
									  sin(cursor_angle) * TRACK_RADIUS
								  )
		draw_circle(cursor_pos, 8, Color.TRANSPARENT)
		draw_arc(cursor_pos, STEP_RADIUS + (STEP_RADIUS * 0.25), 0, TAU, STEP_RADIUS*2, Color.RED)

	# Draw playhead
	var playhead_rad: float   = deg_to_rad(playhead_angle)
	var playhead_end: Vector2 = Vector2(
									cos(playhead_rad) * (TRACK_RADIUS + 20),
									sin(playhead_rad) * (TRACK_RADIUS + 20)
								)
	draw_line(Vector2.ZERO, playhead_end, Color.YELLOW)


func _unhandled_input(event):
	if !controls_locked && event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_LEFT:
					cursor_step = (cursor_step - 1 + NUM_STEPS) % NUM_STEPS
				KEY_RIGHT:
					cursor_step = (cursor_step + 1) % NUM_STEPS
				KEY_UP:
					if(notes[cursor_step] != -1):
						notes[cursor_step] = min(notes[cursor_step] + 1, note_scale.size() - 1)
				KEY_DOWN:
					if(notes[cursor_step] != -1):
						notes[cursor_step] = max(notes[cursor_step] - 1, 0)
				KEY_Z:
					if (notes[cursor_step] >= 0):
						notes[cursor_step] = -1
					else:
						notes[cursor_step] = 0
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
				
					

func play_note(midi_note: int):
	var freq: float = midi_to_freq(midi_note)
	generate_tone(freq, 0.2)  # 200ms note duration

func clear_pattern():
	for i in range(NUM_STEPS):
		notes[i] = -1

func get_current_pattern():
	return notes
	
func set_pattern(new_pattern: Array[int]):
	notes = new_pattern
	
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
	wrong_notes = new_wrong_notes

func clear_wrong_notes() -> void:
	var cleared_wrong_notes: Array[bool] = []
	cleared_wrong_notes.resize(NUM_STEPS)
	wrong_notes = cleared_wrong_notes
	
func lock_controls(locked: bool):
	controls_locked = locked
	
func win_state():
	clear_wrong_notes()
	lock_controls(true)
	
func lose_state():
	lock_controls(true)
	
func play_state():
	playing = true
	lock_controls(false)
