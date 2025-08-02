extends Resource
class_name AudioLibrary

@export var sound_effects:Array[SoundEffect]

func get_audio_stream(_tag: String):
	var i = -1
	if _tag:
		for sound in sound_effects:
			i += 1
			if sound.tag == _tag:
				return sound_effects[i].stream
	else:
		printerr("No tag provided. Can't get sound effect.")
		return null
