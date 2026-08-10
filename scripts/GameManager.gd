extends Node

@export var player_ship_scene: PackedScene

@onready var players: Node = $"../Players"
@onready var player_spawner: MultiplayerSpawner = $"../PlayerMultiplayerSpawner"
@onready var camera: Camera2D = $"../Camera2D"


func _ready():
	NetworkManager.player_connected.connect(_on_peer_connected)
	NetworkManager.player_disconnected.connect(_on_peer_disconnected)

	player_spawner.spawn_function = _spawn_player

	print("Has peer: ", multiplayer.has_multiplayer_peer())
	print("Is server: ", multiplayer.is_server())
	print("Unique ID: ", multiplayer.get_unique_id())

	if multiplayer.has_multiplayer_peer() and multiplayer.is_server():
		print("Scheduling host spawn")
		spawn_player.call_deferred(multiplayer.get_unique_id())


	if multiplayer.is_server():
		print("Generating asteroids")
		call_deferred("generate_asteroids")
		print("Finished generating asteroids")


func _on_peer_connected(peer_id: int):
	print("Player connected: ", peer_id)

	if multiplayer.is_server():
		spawn_player(peer_id)


func _on_peer_disconnected(peer_id: int):
	print("Player disconnected: ", peer_id)

	if not multiplayer.is_server():
		return

	var player = players.get_node_or_null(str(peer_id))

	if player:
		player.queue_free()


func spawn_player(peer_id: int):
	if not multiplayer.is_server():
		return

	print("SERVER spawning ", peer_id)

	var data = {
		"peer_id": peer_id,
		"player_ship_scene_path": player_ship_scene.resource_path
	}

	var result = player_spawner.spawn(data)

	print("Spawner returned: ", result)


func _spawn_player(data: Dictionary) -> Node:
	var peer_id = data["peer_id"]
	var scene = load(data["player_ship_scene_path"])
	print("_spawn_player on local peer ", multiplayer.get_unique_id())
	print("Creating player for peer ", data["peer_id"])

	var player = scene.instantiate()

	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)

	if peer_id == multiplayer.get_unique_id():
		camera.set_target(player)

	return player

func generate_asteroids():
	if not multiplayer.is_server():
		return

	var asteroid_manager = get_tree().current_scene.get_node("AsteroidManager")

	var asteroids = get_tree().current_scene.get_node("Asteroids")

	while true:
		var asteroid_count = asteroids.get_child_count()

		var position = Vector2(
			randf_range(-2000, 2000),
			randf_range(-2000, 2000)
		)

		for asteroid in asteroids.get_children():
			if asteroid.global_position.distance_to(position) < 500:
				print("Too close to existing asteroid, skipping spawn")
				continue

		asteroid_manager.spawn_asteroid(
			load("res://scenes/Asteroids/PlainAsteroid.tscn"),
			position
		)

		if asteroid_count >= 20:
			break
