extends Node

@export var player_ship_scene: PackedScene

@onready var players: Node = $"../Players"
@onready var player_spawner: MultiplayerSpawner = $"../PlayerMultiplayerSpawner"
@onready var camera: Camera2D = $"../Camera2D"
@onready var hud: Node = $"../HUD"
@onready var shop: Control = $"../Shop"
var local_player: BaseShip
var station: BaseStation


func _ready():
	print(
		"GAME READY. Peer: ",
		multiplayer.get_unique_id(),
		" Server: ",
		multiplayer.is_server()
	)

	NetworkManager.player_connected.connect(_on_peer_connected)
	NetworkManager.player_disconnected.connect(_on_peer_disconnected)
	NetworkManager.connected_to_server.connect(_on_connected_to_server)

	player_spawner.spawn_function = _spawn_player

	# Find the space station
	for child in get_tree().current_scene.get_children():
		if child is BaseStation:
			station = child
			print("Found station: ", station.name)
			break

	# Game scene must exist BEFORE creating the SteamMultiplayerPeer.
	if NetworkManager.network_type == NetworkManager.NetworkType.STEAM and NetworkManager.waiting_for_steam_connection:
		print("Steam client scene ready")
		call_deferred("_finish_steam_join")
		return

	# Server, either ENet or Steam.
	if multiplayer.has_multiplayer_peer() and multiplayer.is_server():
		print("Scheduling host spawn")

		# Spawning the host
		spawn_player.call_deferred(
			multiplayer.get_unique_id()
		)

		call_deferred("generate_asteroids")
		return

	# The ENet connection already exists by the time Game.tscn loads, so we can send the client_ready signal immediately.
	if NetworkManager.network_type == NetworkManager.NetworkType.ENET:
		print("ENet client game ready")
		_send_client_ready.call_deferred()

# Function to finish the Steam join process after the game scene is fully loaded
func _finish_steam_join() -> void:
	await get_tree().process_frame

	var error = NetworkManager.finish_steam_connection()

	if error != OK:
		print("Failed to finish Steam connection: ", error)

func _on_connected_to_server() -> void:
	print(
		"GameManager connected as peer ",
		multiplayer.get_unique_id()
	)

	# Steam client's Game.tscn is already ready at this point.
	if NetworkManager.network_type == NetworkManager.NetworkType.STEAM:
		_send_client_ready()

func _send_client_ready() -> void:
	print(
		"Sending client_ready from peer ",
		multiplayer.get_unique_id()
	)

	client_ready.rpc_id(1)


func _on_peer_connected(peer_id: int):
	print("Player connected: ", peer_id)


func _on_peer_disconnected(peer_id: int):
	print("Player disconnected: ", peer_id)

	if not multiplayer.is_server():
		return

	var player = players.get_node_or_null(str(peer_id))

	if player:
		player.queue_free()

@rpc("any_peer", "call_remote", "reliable")
func client_ready():
	print("SERVER: client_ready received")

	if not multiplayer.is_server():
		return

	var peer_id = multiplayer.get_remote_sender_id()
	print("SERVER: ready peer = ", peer_id)

	spawn_player(peer_id)


func spawn_player(peer_id: int):
	if not multiplayer.is_server():
		return

	print("SERVER spawning ", peer_id)

	var docks = station.get_docks()
	var spawn_dock = docks[players.get_child_count()]
	var spawn_position = spawn_dock.global_position

	var data = {
		"peer_id": peer_id,
		"player_ship_scene_path": player_ship_scene.resource_path,
		"spawn_position": spawn_position
	}

	player_spawner.spawn(data)


func _spawn_player(data: Dictionary) -> Node:
	var peer_id = data["peer_id"]
	var scene = load(data["player_ship_scene_path"])
	print("_spawn_player on local peer ", multiplayer.get_unique_id())
	print("Creating player for peer ", data["peer_id"])

	var player = scene.instantiate()

	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	player.global_position = data["spawn_position"]

	if peer_id == multiplayer.get_unique_id():
		camera.set_target(player)
		set_local_player(player)

	return player

func set_local_player(player: BaseShip) -> void:
	local_player = player

func generate_asteroids():
	if not multiplayer.is_server():
		return

	var asteroid_manager = get_tree().current_scene.get_node("AsteroidManager")

	var asteroids = get_tree().current_scene.get_node("Asteroids")
	var i = 0

	while i < 30:
		var to_skip = false
		var asteroid_count = asteroids.get_child_count()

		var position = Vector2(
			randf_range(-2500, 2500),
			randf_range(-2500, 2500)
		)

		for asteroid in asteroids.get_children():
			if asteroid.global_position.distance_to(position) < 250:
				print("Too close to existing asteroid, skipping spawn")
				to_skip = true
			elif asteroid.global_position.distance_to(station.global_position) < 600:
				print("Too close to station, skipping spawn")
				to_skip = true

		if not to_skip:
			asteroid_manager.spawn_asteroid(
				load("res://scenes/asteroids/PlainAsteroid.tscn"),
				position
			)

		if asteroid_count >= 20:
			break

		i += 1

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("shop"):
		if shop.visible:
			shop.close_menu()
			camera.set_target(local_player)
		else:
			shop.open_for_ship(local_player)
			camera.set_target(shop)
