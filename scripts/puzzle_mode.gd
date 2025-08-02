# scripts/classes/puzzle_mode.gd
extends Node
class_name PuzzleMode

signal puzzle_completed(score: int)
signal pattern_check_failed(wrong_notes: Array[bool])
signal level_state_request_change(new_state: PuzzleLevelState.States)

var current_level: PuzzleLevel
var attempts: int = 0
var current_score: int= 0
var total_score: int = 0
var is_playing_goal: bool = false
var original_pattern = []
var level_complete: bool = false

@onready var sequencer = $"../Sequencer"
@onready var ui = $"../PuzzleUI"

func load_level(level: PuzzleLevel) -> void:
	current_level = level
	current_score = level.max_score
	attempts = 0
	sequencer.clear_pattern()
	ui.update_current_score(current_score)
	ui.update_total_score(total_score)

func play_goal_pattern() -> void:
	if (!is_playing_goal):
		is_playing_goal = true
		sequencer.lock_controls(true)
		sequencer.stop()
		original_pattern = sequencer.get_current_pattern()
		sequencer.hide_notes()
		var goal_pattern = current_level.get_goal_pattern()
		sequencer.set_pattern(goal_pattern)
		sequencer.play()

func stop_goal_pattern() -> void:
	if (is_playing_goal):
		sequencer.stop()
		sequencer.set_pattern(original_pattern)
		sequencer.show_notes()
		sequencer.lock_controls(false)
		sequencer.play()
		is_playing_goal = false

func check_pattern() -> bool:
	attempts += 1
	var current_pattern = sequencer.get_current_pattern()
	var wrong_notes: Array[bool]
	wrong_notes.resize(current_pattern.size())

	# Compare patterns and collect wrong notes
	for x in range(len(current_pattern)):
		wrong_notes[x] = current_pattern[x] != current_level.goal_pattern[x]

	if wrong_notes.any(is_true):
		current_score = max(0, current_score - current_level.score_penalty)
		ui.update_current_score(current_score)
		pattern_check_failed.emit(wrong_notes)
		if (current_score <= 0):
			level_state_request_change.emit(PuzzleLevelState.States.LOSE)
		return false
	else:
		total_score += current_score
		ui.update_total_score(total_score)
		puzzle_completed.emit(total_score)
		level_state_request_change.emit(PuzzleLevelState.States.WIN)
		return true

func is_true(val):
	return val
