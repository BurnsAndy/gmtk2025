# scenes/game/puzzle_level_scene.gd
extends Node

@onready var puzzle_mode = $PuzzleMode
@onready var puzzle_ui = $PuzzleUI
@onready var sequencer = $Sequencer
@onready var confetti_emitter = $ConfettiEmitter
@export var level_set: Array[PuzzleLevel]
var current_level: int = -1
var main_menu_scene_path = "res://scenes/main_menu.tscn"
var final_score_scene_path = "res://scenes/final_score_scene.tscn"

var level_state: PuzzleLevelState = PuzzleLevelState.new()
signal level_state_request_change
signal level_state_changed


func _ready() -> void:
	puzzle_mode.pattern_check_failed.connect(sequencer.set_wrong_notes)
	sequencer.pattern_complete.connect(puzzle_mode.stop_goal_pattern)
	sequencer.check_requested.connect(_on_check_requested)
	sequencer.play_goal_requested.connect(puzzle_mode.play_goal_pattern)
	
	change_scene("next_level")

func nextLevel():
	level_state.SetState(PuzzleLevelState.States.LOADING)
	confetti_emitter.cease_celebration()
	puzzle_ui.hide_win_or_lose()
	if current_level < level_set.size() - 1:
		current_level += 1
		level_set[current_level].load_best_score()
		var level = level_set[current_level]
		puzzle_ui.set_level_name(level.level_name)
		puzzle_ui.set_level_description(level.description)
		var loaded_level = load(level.resource_path)
		puzzle_mode.load_level(loaded_level)
		sequencer.setup_tracks(level)
		await wait(.25)
		puzzle_mode.play_goal_pattern()
		sequencer.play_state()
		level_state.SetState(PuzzleLevelState.States.PLAY)
	else:
		change_scene("final_score_win")
		
func go_to_main_menu():
	var scene = load(main_menu_scene_path)
	var instance = scene.instantiate()
	get_tree().root.add_child(instance)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = instance
	
func go_to_final_score(score:int, winner:bool, subtitle: String = ""):
	var scene = load(final_score_scene_path)
	var instance = scene.instantiate()
	instance.winner = winner
	instance.subtitle_value = subtitle
	instance.score_value = score
	get_tree().root.add_child(instance)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = instance

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_ENTER:
					if level_state.GetState() == PuzzleLevelState.States.WIN:
						nextLevel()
					elif level_state.GetState() == PuzzleLevelState.States.LOSE:
						change_scene("final_score_lose")
				KEY_ESCAPE:
					change_scene("main_menu")

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
	level_set[current_level].update_best_score(puzzle_mode.current_score)
	puzzle_ui.show_win_or_lose(true)

func level_lose():
	sequencer.lose_state()
	puzzle_ui.show_win_or_lose(false)

func _on_puzzle_mode_level_state_request_change(new_state: PuzzleLevelState.States) -> void:
	state_request_change(new_state)

func _on_scene_request_change(new_scene: String):
	change_scene(new_scene)
			
func change_scene(new_scene: String):
	match new_scene:
		"main_menu":
			go_to_main_menu()
		"final_score_lose":
			go_to_final_score(puzzle_mode.total_score, false, "Better luck next time!")
		"final_score_win":
			go_to_final_score(puzzle_mode.total_score, true, "You did it!")
		"next_level":
			nextLevel()

func wait(seconds: float) -> void:
	prints("waiting for", seconds)
	await get_tree().create_timer(seconds).timeout
	print("done waiting")
