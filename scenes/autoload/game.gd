extends Node

var player : Player

onready var main = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
onready var menu = main.get_node("menu")
onready var hud = main.get_node("hud")

var knockback = 25
var cooldown = 0.5

# Maps
onready var map_scns = [preload("res://scenes/maps/map.tscn")]
# Controllers
onready var controllers = [
	preload("res://scenes/controllers/player.tscn"),
	preload("res://scenes/controllers/peer.tscn"),
	preload("res://scenes/controllers/bot.tscn")
]
var colors = ["#333d55", "#c59654"]
# Impacts
onready var impact_scns = [preload("res://scenes/impacts/metal.tscn")]

func _ready():
	randomize()

func spawn_sound(stream : AudioStream, origin : Vector3, unit_db : float, lifetime : float):
	var sound = Sound.new()
	sound.lifetime = lifetime
	sound.unit_size = 1.0
	sound.bus = "Sounds"
	sound.doppler_tracking = AudioStreamPlayer3D.DOPPLER_TRACKING_PHYSICS_STEP
	sound.stream = stream
	sound.pitch_scale = rand_range(0.8, 1.2)
	sound.unit_db = unit_db
	main.main_pass.add_child(sound)
	sound.global_transform.origin = origin
	sound.play()

func create_impact(index : int, parent : Node, pos : Vector3, norm : Vector3):
	var impact = impact_scns[index].instance()
	parent.add_child(impact)
	impact.global_transform.origin = pos + norm * 0.01
	impact.look_at(pos + norm, Vector3(1.0, 1.0, 0.0))

func spawn_map(map_id : int):
	var map = map_scns[map_id].instance()
	main.main_pass.add_child(map)

func spawn_gobot(node_name : String, controller_type : int):
	var gobot = controllers[controller_type].instance()
	gobot.name = node_name
	main.main_pass.add_child(gobot)
	gobot.body.global_transform = get_spawn()

func remove_gobot(id : int):
	main.main_pass.get_node(str(id)).free()

func reload():
	for n in main.main_pass.get_children():
		n.queue_free()

func get_spawn():
	var spawns = main.main_pass.get_node_or_null("map/spawns")
	if spawns:
		return spawns.get_child(randi() % spawns.get_child_count()).global_transform
	else:
		return Transform(Basis.IDENTITY, Vector3(0.0, 10.0 + randf(), 0.0))
