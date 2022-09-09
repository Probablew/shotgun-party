extends AudioStreamPlayer3D
class_name Sound

var lifetime : float = 3.0

func _process(delta):
	lifetime -= delta
	if lifetime <= 0.0:
		free()
