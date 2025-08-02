extends Node
const SAVE_FILE = "user://scores.cfg"
var config = ConfigFile.new()

func _ready():
	load_scores()
	
func load_scores():
	var err = config.load(SAVE_FILE)
	if err != OK:
		print("No existing scores file found")
		return

func save_score(level_name: String, score: int):
	var current_best = config.get_value("scores", level_name, 0)
	if score > current_best:
		config.set_value("scores", level_name, score)
		config.save(SAVE_FILE)
		return true
	return false

func get_best_score(level_name: String) -> int:
	return config.get_value("scores", level_name, 0)

func reset_scores():
	config.clear()
	config.save(SAVE_FILE)
