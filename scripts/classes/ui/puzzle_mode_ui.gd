# scripts/ui/puzzle_mode_ui.gd
extends Control

@onready var level_name_label = $VBoxContainer/LevelNameLabel
@onready var level_description_label = $VBoxContainer/LevelDescriptionLabel
@onready var current_score_label = $VBoxContainer/CurrentScoreLabel
@onready var total_score_label = $VBoxContainer/TotalScoreLabel
@onready var win_or_lose_label = $"../WinOrLoseLabel"
@onready var controls_container: VBoxContainer = $VBoxContainer/ControlsContainer



var script_utility = ScriptUtilities.new()

func _ready() -> void:
	win_or_lose_label.position = get_centered_position(win_or_lose_label.size)
	win_or_lose_label.visible = false

func toggle_controls():
	controls_container.visible = !controls_container.visible

func get_centered_position(size: Vector2) -> Vector2:
	var viewport_size: Rect2 = get_viewport_rect()
	var x: float             = viewport_size.size.x/2 - size.x/2
	var y: float             = viewport_size.size.y/2 - size.y/2
	return Vector2(x, y)

func update_current_score(score: int) -> void:
	current_score_label.text = "Score: " + script_utility.int_to_str(score)
	
func update_total_score(score: int) -> void:
	total_score_label.text = "Total Score: " + script_utility.int_to_str(score)
	
func show_win_or_lose(won: bool, last_level: bool = false):
	if won:
		win_or_lose_label.text = "YOU WIN!"
		if last_level:
			win_or_lose_label.text += "\n\nPress [Enter] to \ngo to the Final Score screen..."
		else:
			win_or_lose_label.text += "\n\nPress [Enter] to \ngo to the next level..."
	else:
		win_or_lose_label.text = "YOU LOST!\n\nPress [Enter] to \ngo to the Final Score screen..."
	win_or_lose_label.visible = true
	
func hide_win_or_lose():
	win_or_lose_label.visible = false

func set_level_name(level_name: String):
	level_name_label.text = level_name
	
func set_level_description(level_description: String):
	level_description_label.text = level_description
