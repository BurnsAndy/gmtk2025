# scenes/game/puzzle_level_scene.gd
extends Node

@onready var puzzle_mode = $PuzzleMode
@onready var puzzle_ui = $PuzzleUI
@onready var sequencer = $Sequencer
@onready var confetti_emitter = $ConfettiEmitter
@export var level_set: Array[PuzzleLevel]
var current_level: int = -1

var level_state: PuzzleLevelState = PuzzleLevelState.new()
signal level_state_request_change
signal level_state_changed


func _ready() -> void:
	puzzle_mode.pattern_check_failed.connect(sequencer.set_wrong_notes)
	sequencer.pattern_complete.connect(puzzle_mode.stop_goal_pattern)
	sequencer.check_requested.connect(_on_check_requested)
	sequencer.play_goal_requested.connect(puzzle_mode.play_goal_pattern)
	
	nextLevel()

func nextLevel():
	level_state.SetState(PuzzleLevelState.States.LOADING)
	confetti_emitter.cease_celebration()
	puzzle_ui.hide_win_or_lose()
	if current_level < level_set.size() - 1:
		current_level += 1
		var level = level_set[current_level]
		print(level_set)
		prints(current_level, level.resource_path)
		puzzle_ui.set_level_name(level.level_name)
		puzzle_ui.set_level_description(level.description)
		puzzle_mode.load_level(load(level.resource_path))
		sequencer.play_state()
		puzzle_mode.play_goal_pattern()
		level_state.SetState(PuzzleLevelState.States.PLAY)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_ENTER:
					if level_state.GetState() == PuzzleLevelState.States.WIN:
						nextLevel()

func _on_check_requested() -> void:
	puzzle_mode.check_pattern()

func state_request_change(new_state: PuzzleLevelState.States):
	level_state.SetState(new_state)
	level_state_changed.emit(new_state)
	match new_state:
		PuzzleLevelState.States.WIN:
			level_win()
		PuzzleLevelState.States.LOSE:
			level_lose()

func level_win():
	confetti_emitter.celebrate()
	sequencer.win_state()
	puzzle_ui.show_win_or_lose(true)
	pass

func level_lose():
	sequencer.lose_state()
	puzzle_ui.show_win_or_lose(false)
	pass

func _on_puzzle_mode_level_state_request_change(new_state: PuzzleLevelState.States) -> void:
	state_request_change(new_state)
