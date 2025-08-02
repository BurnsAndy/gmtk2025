# scripts/ui/puzzle_mode_ui.gd
extends Control

@onready var level_name_label = $LevelNameLabel
@onready var level_description_label = $LevelDescriptionLabel
@onready var current_score_label = $CurrentScoreLabel
@onready var total_score_label = $TotalScoreLabel
@onready var win_or_lose_label = $WinOrLoseLabel

var script_utility = ScriptUtilities.new()

func _ready() -> void:
	win_or_lose_label.position = get_centered_position(win_or_lose_label.size)
	win_or_lose_label.visible = false

func get_centered_position(size: Vector2) -> Vector2:
	var viewport_size: Rect2 = get_viewport_rect()
	var x: float             = viewport_size.size.x/2 - size.x/2
	var y: float             = viewport_size.size.y/2 - size.y/2
	return Vector2(x, y)

func update_current_score(score: int) -> void:
	current_score_label.text = "Score: " + script_utility.int_to_str(score)
	
func update_total_score(score: int) -> void:
	total_score_label.text = "Total Score: " + script_utility.int_to_str(score)
	
func show_win_or_lose(won: bool):
	if won:
		win_or_lose_label.text = "You win!"
	else:
		win_or_lose_label.text = "You lost!"
	win_or_lose_label.visible = true
	
func hide_win_or_lose():
	win_or_lose_label.visible = false

func set_level_name(level_name: String):
	level_name_label.text = level_name
	
func set_level_description(level_description: String):
	level_description_label.text = level_description
