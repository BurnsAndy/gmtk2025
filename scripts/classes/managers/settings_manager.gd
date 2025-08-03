extends Node

const SAVE_FILE = "user://settings.cfg"
const MAX_VOL: float = 0.6 #game is loud as fuck, setting max volume
var config = ConfigFile.new()

func _ready():
	load_settings()
	apply_volume()

func load_settings():
	var err = config.load(SAVE_FILE)
	if err != OK:
		print("No existing settings file found. Using defaults.")
		return

func save_settings():
	config.save(SAVE_FILE)

func set_master_volume(value: float):
	var adjusted_value = (MAX_VOL * value) / 100
	var volume_db = linear_to_db(adjusted_value) 
	prints("adjusting vol to ", (adjusted_value*100), "%, ", volume_db, "db")
	AudioServer.set_bus_volume_db(0, volume_db)
	config.set_value("audio", "master_volume", value)
	save_settings()

func get_master_volume() -> float:
	return config.get_value("audio", "master_volume", 100.0)

func apply_volume():
	set_master_volume(get_master_volume())
