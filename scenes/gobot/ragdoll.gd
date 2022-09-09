extends Skeleton
class_name Ragdoll

var body : BaseBody
var lifetime : float = 3.0

func _process(delta):
	lifetime -= delta
	if lifetime <= 0.0:
		body.clear_ragdoll()
		queue_free()
