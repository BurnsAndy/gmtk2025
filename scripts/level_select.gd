extends Node2D
@export var all_levels: Array[PuzzleLevel]
@onready var flow_container = $FlowContainer

signal play_level

func _ready():
	var level_select_template_scene = load("res://scenes/level_select_template.tscn")
	for i in range(all_levels.size()):
		var instance = level_select_template_scene.instantiate()
		instance.puzzle_level = all_levels[i]
		flow_container.add_child(instance)
