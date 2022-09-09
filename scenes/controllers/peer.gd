extends Controller
class_name Peer

func _ready():
	body.weapon = $holder/weapons/weapon
	body.weapon.shooter = body

func _physics_process(delta):
	if !body.dead:
		body.process_steps(delta)
		body.process_anims(delta)

func update(t : Vector3, ry : float, hrx : float, vel : Vector3, f : bool, ap : bool):
	# Interpolate translation and rotation
	$tween.interpolate_property(body, "translation", body.translation, t, Net.HOST_RATE, Tween.TRANS_LINEAR)
	$tween.interpolate_property(body, "transform:basis", body.transform.basis, Basis(Vector3(body.rotation.x, ry, body.rotation.z)), Net.HOST_RATE, Tween.TRANS_LINEAR)
	$tween.start()
	# Head rotation already interpolated within animation process
	body.head.rotation.x = hrx
	body.vel = vel
	body.is_on_floor = f
	if ap:
		body.weapon.primary()
