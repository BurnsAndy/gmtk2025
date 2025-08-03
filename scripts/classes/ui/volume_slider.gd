extends HSlider

func _ready():
	min_value = 0
	max_value = 100
	step = 1
	value = SettingsManager.get_master_volume()
	print("slider says", value)
	value_changed.connect(_on_value_changed)

func _on_value_changed(new_value: float):
	print("slider now says", new_value)
	SettingsManager.set_master_volume(new_value)
