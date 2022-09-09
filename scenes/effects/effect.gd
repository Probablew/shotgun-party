extends Spatial
class_name Effect

var lifetime : float = 1.0

func _process(delta):
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
