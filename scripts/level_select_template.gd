extends Panel

@export var puzzle_level: PuzzleLevel
@onready var level_details_label = $ColorRect/LevelDetailsRichTextLabel
@onready var play_level_button = $ColorRect/PlayLevelButton
const puzzle_level_scene = preload("res://scenes/puzzle_level_scene.tscn")
var script_utility = ScriptUtilities.new()

func _ready():
	level_details_label.text = puzzle_level.level_name + "\n" + puzzle_level.description + "\nBest Score: " + script_utility.int_to_str(puzzle_level.best_score)
	play_level_button.pressed.connect(_play_level_button_pressed)

func _play_level_button_pressed():
	var instance = puzzle_level_scene.instantiate()
	var levels: Array[PuzzleLevel] = [puzzle_level]
	instance.level_set = levels
	get_tree().root.add_child(instance)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = instance
