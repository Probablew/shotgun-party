extends Node

const PORT : int = 6969
const MAX_PLAYERS : int = 64
const HOST_RATE : float = 1.0/20.0
const PEER_RATE : float = 1.0/60.0

var update_timer : float = 0.0

var bot_count : int = 0
signal host_config_updated

func _ready():
	var _host_config_connect = connect("host_config_updated", self, "_on_host_config_updated")

func _physics_process(delta):
	if is_instance_valid(Game.player) and get_tree().network_peer:
		update_timer -= delta
		if update_timer <= 0.0:
			if is_server():
				update_timer = HOST_RATE
				var world_state = [[]]
				for body in get_tree().get_nodes_in_group("gobots"):
					world_state[0].push_back([body.owner.name, body.translation, body.rotation.y, body.head.rotation.x, body.vel, body.is_on_floor(), body.action_primary])
				rpc_unreliable("update_world", world_state)
			else:
				update_timer = PEER_RATE
				var body = Game.player.body
				rpc_unreliable_id(1, "update_peer", body.translation, body.rotation.y, body.head.rotation.x, body.vel, body.is_on_floor(), body.action_primary)

func is_server():
	return get_tree().is_network_server()

func reset():
	get_tree().network_peer = null

func create_client(address : String):
	# Connect network events
	var _peer_connected = get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	var _peer_disconnected = get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	var _connected_to_server = get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	var _connection_failed = get_tree().connect("connection_failed", self, "_on_connection_failed")
	var _server_disconnected = get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	# Set up an ENet instance
	var network = NetworkedMultiplayerENet.new()
	network.create_client(address, PORT)
	get_tree().set_network_peer(network)

func create_server():
	# Connect network events
	var _peer_connected = get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	var _peer_disconnected = get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	# Set up an ENet instance
	var network = NetworkedMultiplayerENet.new()
	network.create_server(PORT, MAX_PLAYERS)
	get_tree().set_network_peer(network)

func _on_peer_connected(id):
	# When other players connect a character with the controller type of Peer is created
	Game.spawn_gobot(str(id), 1)
	if is_server():
		rpc_id(id, "update_host_config", bot_count)

func _on_peer_disconnected(id):
	# Remove unused character when player disconnects
	Game.remove_gobot(id)

func _on_connected_to_server():
	# Upon successful connection get the unique network ID
	# This ID is used to name the character node so the network can distinguish the characters
	# Hide a menu
	Game.menu.visible = false
	Game.menu.get_node("drone").stop()
	# Spawn map
	Game.spawn_map(0)

func _on_host_config_updated():
	# After getting the host config
	# Create an actual controllable character for us
	var id = get_tree().get_network_unique_id()
	# Create bots
	Game.spawn_gobot(str(id), 0)
	for i in bot_count:
		Game.spawn_gobot("bot" + str(i), 2)

func _on_connection_failed():
	Game.menu.visible = true
	Game.menu.show_message("Connection failed")
	# Upon failed connection reset the RPC system
	get_tree().set_network_peer(null)

func _on_server_disconnected():
	# If server disconnects just reload the game
	var _reloaded = get_tree().reload_current_scene()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

puppet func update_world(world_state : Array):
	for gobot in world_state[0]:
		if int(gobot[0]) == get_tree().get_network_unique_id():
			continue
		Game.main.main_pass.get_node(gobot[0]).update(gobot[1], gobot[2], gobot[3], gobot[4], gobot[5], gobot[6])

puppet func update_host_config(new_bot_count : int):
	bot_count = new_bot_count
	emit_signal("host_config_updated")

remote func update_peer(t : Vector3, ry : float, hrx : float , v : Vector3, f : bool, ap : bool):
	var peer_gobot = Game.main.main_pass.get_node(str(get_tree().get_rpc_sender_id())).body
	peer_gobot.translation = t
	peer_gobot.rotation.y = ry
	peer_gobot.head.rotation.x = hrx
	peer_gobot.vel = v
	peer_gobot.is_on_floor = f
	if ap:
		peer_gobot.weapon.primary()
