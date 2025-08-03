extends Panel

@export var puzzle_level: PuzzleLevel
@onready var level_details_label = $ColorRect/LevelDetailsRichTextLabel
@onready var play_level_button = $ColorRect/PlayLevelButton
@onready var color_rect: ColorRect = $ColorRect

const puzzle_level_scene = preload("res://scenes/puzzle_level_scene.tscn")
var script_utility = ScriptUtilities.new()

const BG_COLORS: Dictionary = {
									0: Color(0.0, 0.08627451, 0.101960786),
									1: Color(0.85882354, 0.32941177, 0.38039216), 
									2: Color(0.94509804, 0.63529414, 0.03137255), 
									3: Color(0.03137255, 0.69803923, 0.8901961),
									4: Color(0.105882354, 0.6, 0.54509807)
								}


func _ready():
	level_details_label.text = puzzle_level.level_name + "\n" + puzzle_level.description + "\nBest Score: " + script_utility.int_to_str(puzzle_level.best_score)
	color_bg(puzzle_level.best_score, puzzle_level.max_score)
	play_level_button.pressed.connect(_play_level_button_pressed)
	
func color_bg(best_score:int, max_score:int):
	var did_you_do_a_good_job: float = float(best_score)/ float(max_score)
	
	if did_you_do_a_good_job == 1:
		color_rect.color = BG_COLORS[4]
	elif did_you_do_a_good_job > 0.8:
		color_rect.color = BG_COLORS[3]
	elif did_you_do_a_good_job > 0.5:
		color_rect.color = BG_COLORS[2]
	elif did_you_do_a_good_job > 0.1:
		color_rect.color = BG_COLORS[1]
	elif did_you_do_a_good_job > -1:
		color_rect.color = BG_COLORS[0]

func _play_level_button_pressed():
	var instance = puzzle_level_scene.instantiate()
	var levels: Array[PuzzleLevel] = [puzzle_level]
	instance.level_set = levels
	get_tree().root.add_child(instance)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = instance
