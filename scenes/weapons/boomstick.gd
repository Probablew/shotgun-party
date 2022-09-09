extends Weapon
class_name Boomstick

const MAX_LENGTH : float = 1000.0
var COOLDOWN : float = 0.5
var KNOCKBACK : float = 25.0
const MAX_PELLETS : int = 4
const MAX_PELLET_DAMAGE : float = 25.0
const SPREAD : float = 50.0

var muzzle : Position3D
export var muzzle_path : NodePath

var trace_scn = preload("res://scenes/weapons/trace.tscn")
var flash_scn = preload("res://scenes/effects/flash.tscn")
var cd_timer : float = 0.0

func _ready():
	muzzle = $muzzle
	if muzzle_path:
		muzzle = get_node(muzzle_path)
		
func _process(delta):
	COOLDOWN = Game.cooldown
	KNOCKBACK = Game.knockback

func _physics_process(delta):
	if cd_timer > 0.0:
		cd_timer -= delta

func primary():
	if shooter and !shooter.dead and cd_timer <= 0.0:
		# Reset cooldown
		cd_timer = COOLDOWN
		# Camera shake
		var holder = shooter.owner.get_node("holder")
		if shooter.owner is Player:
			holder.shake(0.75, 0.33, 1.5)
		# Knockback
		if !shooter.is_on_floor():
			var impulse_dir = holder.transform.basis.z
			var impulse = Vector3(impulse_dir.x, impulse_dir.y * 0.5, impulse_dir.z)
			shooter.add_impulse(impulse * KNOCKBACK)
		# Flash
		var flash = flash_scn.instance()
		muzzle.add_child(flash)
		flash.global_transform = muzzle.global_transform
		var _next_frame_transform = muzzle.global_transform
		#next_frame_transform.origin += shooter.vel * get_physics_process_delta_time()
		# Raycast
		var ray_dss = get_world().direct_space_state
		# Central ray
		for p in MAX_PELLETS:
			var ray_from = shooter.head.global_transform.origin
			var ray_to = ray_from + (shooter.head.global_transform.basis.z * -MAX_LENGTH) + random_spread(SPREAD)
			var ray_result = ray_dss.intersect_ray(ray_from, ray_to, [shooter])
			if ray_result:
				if ray_result.collider is BaseBody:
					var impulse = (ray_result.position - ray_from).normalized() * 15.0
					ray_result.collider.add_impulse(impulse)
					ray_result.collider.hit(MAX_PELLET_DAMAGE * rand_range(0.9, 1.0), shooter)
					Game.create_impact(0, ray_result.collider, ray_result.position, ray_result.normal)
				if ray_result.collider is StaticBody:
					Game.create_impact(0, ray_result.collider, ray_result.position, ray_result.normal)
		# Visual ray
#		var vray_from = next_frame_transform.origin
#		var vray_result = ray_dss.intersect_ray(vray_from, ray_to, [shooter])
#		var trace = trace_scn.instance()
#		Game.main.main_pass.add_child(trace)
#		trace.global_transform = next_frame_transform
#		var trace_length = MAX_LENGTH
#		if vray_result:
#			trace_length = vray_from.distance_to(vray_result.position)
#		trace.global_transform.origin -= muzzle.global_transform.basis.z * trace_length * 0.5
#		trace.get_node("mesh_instance").mesh.set("height", trace_length)
#		if ray_result:
#			trace.look_at(ray_result.position, Vector3.UP)

func random_spread(spread : float):
	return Vector3(rand_range(-spread, spread), rand_range(-spread, spread), rand_range(-spread, spread))
