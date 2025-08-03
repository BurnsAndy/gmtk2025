extends Node2D
@export var all_levels: Array[PuzzleLevel]
@onready var flow_container = $FlowContainer

signal play_level

func _ready():
	var level_select_template_scene = load("res://scenes/level_select_template.tscn")
	for i in range(all_levels.size()):
		var instance = level_select_template_scene.instantiate()
		all_levels[i].load_best_score()
		instance.puzzle_level = all_levels[i]
		flow_container.add_child(instance)
		
func _unhandled_input(event):
	if event is InputEventKey && event.pressed && event.keycode == KEY_ESCAPE:
		go_to_main_menu()

func go_to_main_menu():
	var scene = load("res://scenes/main_menu.tscn")
	var instance = scene.instantiate()
	get_tree().root.add_child(instance)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = instance
