# ConfettiEffect.gd
extends GPUParticles2D

func _ready():
	# Start emitting disabled
	emitting = false
	var viewport_size: Rect2 = get_viewport_rect()
	position = Vector2(viewport_size.size.x/2, -10)

func celebrate():
	emitting = true
	
func cease_celebration():
	restart()
	emitting = false
