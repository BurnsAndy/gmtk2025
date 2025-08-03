# scripts/resources/puzzle_level.gd
extends Resource
class_name PuzzleLevel

@export var level_name: String
@export var description: String
@export var bpm: int = 120
@export var max_score: int = 1000      # Starting score
@export var score_penalty: int = 100    # Points deducted per check
@export var best_score: int = 0
@export var track_settings: Array[SequencerTrackSettings] = []
@export var cubes: bool

func load_best_score():
	best_score = ScoreManager.get_best_score(level_name)

func update_best_score(new_score: int):
	if ScoreManager.save_score(level_name, new_score):
		best_score = new_score
		return true
	return false

func get_goal_pattern():
	var goal_pattern = []
	goal_pattern.resize(track_settings.size())
	for i in range(track_settings.size()):
		goal_pattern[i] = track_settings[i].goal_pattern
	return goal_pattern
