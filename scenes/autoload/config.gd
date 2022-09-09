extends Node
# Config autoload

const CUSTOM_CONFIG_PATH = "user://custom.cfg"

const RESOLUTIONS = [
	Vector2(426, 240), 
	Vector2(640, 360),
	Vector2(854, 480), 
	Vector2(1280, 720), 
	Vector2(1920, 1080), 
	Vector2(2560, 1440), 
	Vector2(3840, 2160)
]

var res : int = 3
var res_scale : float = 1.0

onready var main_pass : ViewportContainer = Game.main.get_node(Game.main.main_pass_path).get_parent()

func _ready():
	load_config()

func load_config():
	var config = ConfigFile.new()
	var valid = config.load(CUSTOM_CONFIG_PATH) == OK
	if valid:
		valid = config.has_section("input") and config.has_section("custom")
	if !valid:
		save_config()
	for section in config.get_sections():
		match section:
			"input":
				for key in config.get_section_keys(section):
					InputMap.action_erase_events(key)
					var events = config.get_value(section, key)
					for event in events:
						InputMap.action_add_event(key, event)
			"custom":
				res = config.get_value(section, "res")
				res_scale = config.get_value(section, "res_scale")
				

func save_config():
	var config = ConfigFile.new()
	# Actions
	for action in InputMap.get_actions():
		config.set_value("input", action, InputMap.get_action_list(action))
	# Other settings
	config.set_value("custom", "res", res)
	config.set_value("custom", "res_scale", res_scale)
	config.save(CUSTOM_CONFIG_PATH)

func apply_config():
	# Resolution
	# main_pass.get_child(0).get_texture().flags = Texture.FLAG_FILTER
	main_pass.get_child(0).size = RESOLUTIONS[res]
	# Resolution scale
	main_pass.stretch_shrink = int(1 / res_scale)
