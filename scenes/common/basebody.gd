extends KinematicBody
class_name BaseBody

export var MAX_GRAVITY : float = 32.0
export var MAX_SPEED : float = 16.0
export var MAX_ACCEL : float = 160.0
export var JUMP_FORCE : float = 12.0
export var DROP_FRICTION : float = 0.90
export var DROP_DRAG : float = 0.99

# Direction and velocity
var dir : Vector3
var vel : Vector3
var snap : Vector3

var action_jump : bool = false
var action_primary : bool = false
var action_secondary : bool = false

var is_on_slope : bool = false
var was_near_wall : bool = false
var can_wall_jump : bool = false
var wall_normal : Vector3
var p_jump : bool = false

var health : float
var dead : bool = false

var weapon : Weapon

func process_body(delta):
	dir = dir.normalized()
	
	# Horizontal velocity without gravity
	var hvel = vel
	hvel.y = 0
	var cur_speed : float = hvel.dot(dir)
	
	# Friction if grounded, drag elsewise
	var fric = DROP_FRICTION if is_on_floor() else DROP_DRAG
	hvel *= fric
	if hvel.length() < MAX_SPEED * 0.01:
		hvel = Vector3.ZERO
	
	# Acceleration
	var add_speed : float = clamp(MAX_SPEED - cur_speed, 0.0, MAX_ACCEL * delta)
	hvel += dir * add_speed
	
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide_with_snap(vel, snap, Vector3.UP, true, 3, 0.78, false)
	dir = Vector3.ZERO
	
	# Wall jump
	if action_jump and was_near_wall and can_wall_jump and !p_jump:
		can_wall_jump = false
		add_impulse((wall_normal.normalized() + Vector3.UP) * JUMP_FORCE)
	if !was_near_wall:
		can_wall_jump = true
	
	# Jumping and snapping to ground
	if is_on_floor():
		was_near_wall = false
		if action_jump:
			snap = Vector3.ZERO
			vel.y = JUMP_FORCE
		else:
			snap = -get_floor_normal()
	else:
		snap = Vector3.DOWN
		var grav = MAX_GRAVITY
		if is_near_wall() and cur_speed >= MAX_SPEED * 0.5:
			was_near_wall = true
			grav = MAX_GRAVITY * 0.5
		else:
			was_near_wall = false
		vel.y -= grav * delta
	
	# Bounds
	if translation.y <= -100.0:
		global_transform = Game.get_spawn()
	
	# Weapons
	if weapon and action_primary:
		weapon.primary()
	
	# Check if jump was released or not
	p_jump = action_jump

func hit(_damage : float, _dealer : KinematicBody):
	pass

func add_impulse(impulse : Vector3):
	vel += impulse

func is_near_wall():
	if has_node("rays_wall"):
		var rays = get_node("rays_wall").get_children()
		for ray in rays:
			if ray.is_colliding():
				wall_normal = ray.get_collision_normal()
				return true
