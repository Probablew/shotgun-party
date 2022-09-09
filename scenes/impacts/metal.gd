extends Spatial

var lifetime : float = 1.0

func _ready():
	$sound.pitch_scale = rand_range(0.8, 1.2)
	$impact.restart()
	$dust.restart()
	$sparks.restart()
	lifetime = $impact.lifetime

func _process(delta):
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
