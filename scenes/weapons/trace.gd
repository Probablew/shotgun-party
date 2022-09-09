extends Spatial

var lifetime : float = 0.3

func _ready():
	$tween.interpolate_property($mesh_instance, "mesh:material:albedo_color:a", 0.0, 1.0, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.0)
	$tween.interpolate_property($mesh_instance, "mesh:material:albedo_color:a", 1.0, 0.0, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.15)
	$tween.interpolate_property($mesh_instance, "scale", Vector3(3.0, 1.0, 1.0), Vector3(0.8, 1.0, 0.8), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.0)
	$tween.start()

func _process(delta):
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
