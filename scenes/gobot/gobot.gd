extends BaseBody

var head : Spatial

var color : Color = Color(Game.colors[0])

# Animations
const ALMOST_NINETY : float = 1.5
var asmp : AnimationNodeStateMachinePlayback
var aim_blend : float

# Ragdoll
var ragdoll : Ragdoll
var last_impulse : Vector3
var ragdoll_scn = preload("res://scenes/gobot/ragdoll.tscn")

# Footsteps
var is_on_floor : bool = false
var is_near_floor : bool = false
var was_near_floor : bool = false
var was_was_near_wall : bool = false
var step_timer : float = 0.0
onready var jump_sound = preload("res://sounds/gobot/jump.wav")
onready var land_sound = preload("res://sounds/gobot/land.wav")
onready var step_sounds = [
	preload("res://sounds/gobot/step_1.wav"),
	preload("res://sounds/gobot/step_2.wav"),
	preload("res://sounds/gobot/step_3.wav")
]

func _ready():
	health = 100.0
	head = $head
	$model/animation_tree.active = true
	asmp = $model/animation_tree.get("parameters/sm/playback")
	color = Color(Game.colors[randi() % Game.colors.size()])
	$model/skeleton/mesh_instance.get_surface_material(0).set_shader_param("color", color)
	add_to_group("gobots")
	
func process_anims(delta):
	# Animation states
	if is_on_floor or was_near_wall:
		asmp.travel("ground")
	else:
		asmp.travel("air")
	# Movement blend
	var blend_pos : Vector2 = Vector2.ZERO
	blend_pos.x = range_lerp(vel.dot(global_transform.basis.x), 0.0, MAX_SPEED, 0.0, 1.0)
	blend_pos.y = range_lerp(vel.dot(global_transform.basis.z * -1), 0.0, MAX_SPEED, 0.0, 1.0)
	$model/animation_tree.set("parameters/sm/ground/blend_position", blend_pos)
	# Aim up and down
	var aim_target = clamp(sin(head.rotation.x), -ALMOST_NINETY, ALMOST_NINETY)
	aim_blend = lerp_angle(aim_blend, aim_target, delta * 5.0)
	$model/animation_tree.set("parameters/aim_blend/blend_position", aim_blend)
	# TODO: Add fire animation
	if action_primary:
		$model/animation_tree.set("parameters/fire/active", true)

func spawn_ragdoll():
	ragdoll = ragdoll_scn.instance()
	ragdoll.body = self
	ragdoll.get_node("mesh_instance").get_surface_material(0).set_shader_param("color", color)
	Game.main.main_pass.add_child(ragdoll)
	ragdoll.global_transform = $model/skeleton.global_transform
	for i in ragdoll.get_bone_count():
		ragdoll.set_bone_pose(i, $model/skeleton.get_bone_pose(i))
	ragdoll.physical_bones_start_simulation()
	if ragdoll.get_child_count() > 1:
		for i in ragdoll.get_child_count():
			var child = ragdoll.get_child(i)
			if child is PhysicalBone:
				child.apply_central_impulse(last_impulse)

func clear_ragdoll():
	ragdoll = null
	head.transform.origin = Vector3(0.0, 1.5, 0.0)
	if owner and owner is Player:
		owner.get_node("holder/camera").translation.z = 0.0

func hit(damage : float, dealer : KinematicBody):
	.hit(damage, dealer)
	health -= damage
	if health <= 0.0 and !dead:
		die()

func add_impulse(impulse : Vector3):
	.add_impulse(impulse)
	last_impulse = impulse

func die():
	dead = true
	visible = false
	$collision_shape.disabled = true
	if owner and owner is Player:
		owner.get_node("holder").visible = false
	spawn_ragdoll()
	$respawn.start()

func respawn():
	dead = false
	health = 100.0
	vel = Vector3.ZERO
	visible = true
	$collision_shape.disabled = false
	if owner and owner is Player:
		owner.get_node("holder").visible = true
	global_transform = Game.get_spawn()

func process_steps(delta):
	step_timer -= delta
	if step_timer <= 0.0 and dir.dot(vel) > 0.1 and (is_on_floor or was_near_wall):
		step_timer = 0.33
		Game.spawn_sound(step_sounds[randi() % step_sounds.size()], $ray_ground.global_transform.origin, 0.0, 0.5)
	is_near_floor = $ray_ground.is_colliding()
	if is_near_floor == true and was_near_floor == false:
		Game.spawn_sound(land_sound, $ray_ground.global_transform.origin, -8.0, 1.0)
	if (is_near_floor == false and was_near_floor == true) or (was_near_wall == false and was_was_near_wall == true):
		Game.spawn_sound(jump_sound, $ray_ground.global_transform.origin, -8.0, 1.0)
	was_near_floor = is_near_floor
	was_was_near_wall = was_near_wall

func _on_respawn_timeout():
	respawn()
