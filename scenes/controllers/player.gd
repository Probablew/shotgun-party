extends Controller
class_name Player

# Mouse
var mouse_sens : float = 3.0
var relative : Vector2

# Leaning
const CAM_LEAN_AMOUNT : float = 0.05
var cam_lean : float = 0.0

var menu : Control
var hud : Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	menu = Game.menu
	hud = Game.hud
	hud.visible = true
	Game.player = self
	# Weapon testing
	body.weapon = $holder/weapons/weapon
	body.weapon.shooter = body

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		relative = event.relative

func _process(delta):
	hud.get_node("fps").text = "FPS: " + str(1.0/delta if delta > 0.0 else 1.0)
	hud.get_node("vel").text = "VEL: " + str(body.vel.length())

func _physics_process(delta):
	process_menu()
	process_pivot()
	if !body.dead:
		if !menu.visible:
			process_input()
		process_camera_lean(delta)
		body.process_steps(delta)
		body.process_body(delta)
		body.is_on_floor = body.is_on_floor()
		body.process_anims(delta)

func process_menu():
	if Input.is_action_just_pressed("ui_cancel"):
		if menu.visible and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			menu.visible = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			menu.visible = true
		hud.visible = !menu.visible

func process_pivot():
	var shrink = Game.main.main_pass.get_parent().stretch_shrink
	body.head.rotation.x += relative.y * mouse_sens * -0.001 * shrink
	body.head.rotation.x = clamp(body.head.rotation.x, -1.5, 1.5)
	body.rotation.y += relative.x * mouse_sens * -0.001 * shrink
	if abs(body.rotation.y) >= TAU:
		body.rotation.y = 0.0
	relative = Vector2.ZERO
	$holder.global_transform = body.head.global_transform
	if body.ragdoll != null:
		body.head.global_transform.origin = body.ragdoll.get_node("pelvis").global_transform.origin
		$holder/camera.translation.z = 3.0

func process_input():
	body.dir += (Input.get_action_strength("backward") - Input.get_action_strength("forward")) * body.global_transform.basis.z
	body.dir += (Input.get_action_strength("right") - Input.get_action_strength("left")) * body.global_transform.basis.x
	body.action_jump = Input.is_action_pressed("jump")
	body.action_primary = Input.is_action_pressed("primary")
	body.action_secondary = Input.is_action_pressed("secondary")

func process_camera_lean(delta):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var cam_lean_target = (Input.get_action_strength("left") - Input.get_action_strength("right")) * CAM_LEAN_AMOUNT
		cam_lean_target += float(body.was_near_wall) * body.global_transform.basis.z.cross(body.wall_normal).dot(Vector3.UP) * -0.25
		cam_lean = lerp(cam_lean, cam_lean_target, delta * 15.0)
		$holder.rotation.z = cam_lean
