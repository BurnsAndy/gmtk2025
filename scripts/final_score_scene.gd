extends Node2D

@export var title_value: String = "Final Score"
@export var subtitle_value: String = "You're winner!"
@export var score_value: int = 1000000
@export var winner: bool = true

@onready var title_label = $Control/BoxContainer/TitleRichTextLabel
@onready var subtitle_label = $Control/BoxContainer/SubtitleRichTextLabel
@onready var score_label = $Control/BoxContainer/ScoreRichTextLabel
@onready var menu_button = $Control/BoxContainer/ReturnToMenuButton
@onready var background_color = $Control/BgColorRect
@onready var confetti = $ConfettiEmitter

const color_winrar:Color = Color(0.105882354, 0.6, 0.54509807)
const color_youre_a_loser:Color = Color(0.85882354, 0.32941177, 0.38039216)

var script_utility = ScriptUtilities.new()

func _ready():
	menu_button.pressed.connect(_MenuButton_pressed)
	title_label.text = title_value
	subtitle_label.text = "[i]" + subtitle_value + "[/i]"
	score_label.text = script_utility.int_to_str(score_value)
	if winner:
		background_color.color = color_winrar;
		score_label.text = "[wave amp=50.0 freq=5.0 connected=1]" + score_label.text + "[/wave]" 
		confetti.celebrate()
	else:
		background_color.color = color_youre_a_loser;
		score_label.text = "[shake rate=10.0 level=5 connected=1]" + score_label.text + "[/shake]"
	
func _MenuButton_pressed():
	var scene = load("res://scenes/main_menu.tscn")
	var instance = scene.instantiate()
	get_tree().root.add_child(instance)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = instance
