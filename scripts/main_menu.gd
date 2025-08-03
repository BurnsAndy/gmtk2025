extends Node
@onready var PlayAllLevelsButton = $MainMenuUI/BoxContainer/PlayAllLevelsButton
@onready var FreeplayModeButton = $MainMenuUI/BoxContainer/FreeplayModeButton
@onready var LevelSelectButton = $MainMenuUI/BoxContainer/LevelSelectButton
@onready var polyphonic_audio_player: AudioStreamPlayer2D = $PolyphonicAudioPlayer
@export var all_levels: Array[PuzzleLevel]
const puzzle_level_scene = preload("res://scenes/puzzle_level_scene.tscn")
const level_select_scene = preload("res://scenes/level_select.tscn")


func _ready() -> void:
	PlayAllLevelsButton.pressed.connect(_PlayAllLevelsButtons_pressed)
	FreeplayModeButton.pressed.connect(_FreeplayModeButton_pressed)
	LevelSelectButton.pressed.connect(_LevelSelectButton_pressed)
	polyphonic_audio_player.play_sound_effect_from_library("theme")
	
func _PlayAllLevelsButtons_pressed():
	var instance = puzzle_level_scene.instantiate()
	
	#set any properties for the scene here
	instance.level_set = all_levels
	
	get_tree().root.add_child(instance)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = instance
	
func _FreeplayModeButton_pressed():
	pass
	
func _LevelSelectButton_pressed():
	var instance = level_select_scene.instantiate()
	instance.all_levels = all_levels
	get_tree().root.add_child(instance)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = instance
	
