extends Effect

func _ready():
	lifetime = 2.0
	$sound.pitch_scale = rand_range(0.9, 1.1)
	$particles.restart()
