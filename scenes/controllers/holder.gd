extends Spatial

# Shake
export (OpenSimplexNoise) var noise
var shake_amt : float = 0.0
var shake_dur : float = 0.0
var shake_frq : float = 0.0

# Sway
const SWAY_AMOUNT : float = 1.0
const SWAY_MAX : float = 0.3
const SWAY_SPEED : float = 15.0
var sway : Vector2

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		sway = event.relative

func _physics_process(delta):
	# Shake
	if shake_dur > 0.0:
		shake_dur -= delta
		var shake_offset = shake_dur * shake_frq * 100.0
		$camera.translation.x = noise.get_noise_3d(shake_offset, 0.0, 0.0) * shake_amt * shake_dur
		$camera.translation.y = noise.get_noise_3d(0.0, shake_offset, 0.0) * shake_amt * shake_dur
		var noise_z = noise.get_noise_3d(0.0, 0.0, shake_offset) * shake_amt * shake_dur
		$camera.rotation.x = noise_z * 2.0
		$camera.rotation.y = noise_z * 1.5
		$camera.rotation.z = noise_z
	# Sway
	$weapons.rotation.x = lerp($weapons.rotation.x, clamp(sway.y * SWAY_AMOUNT * delta, -SWAY_MAX, SWAY_MAX), SWAY_SPEED * delta)
	$weapons.rotation.y = lerp($weapons.rotation.y, clamp(sway.x * SWAY_AMOUNT * delta, -SWAY_MAX, SWAY_MAX), SWAY_SPEED * delta)
	sway = Vector2.ZERO

func shake(amount : float, duration : float, frequency : float):
	shake_amt = amount
	shake_dur = duration
	shake_frq = frequency
	noise.seed = randi()
