extends Node

@onready var asteroid_spawner: MultiplayerSpawner = $"../AsteroidMultiplayerSpawner"


func _ready():
	asteroid_spawner.spawn_function = _spawn_asteroid

func spawn_asteroid(scene: PackedScene, position: Vector2):
	if not multiplayer.is_server():
		return

	var data = {
		"scene_path": scene.resource_path,
		"position": position
	}

	asteroid_spawner.spawn(data)

func _spawn_asteroid(data: Dictionary) -> Node:
	var scene: PackedScene = load(data["scene_path"])

	var asteroid = scene.instantiate()

	asteroid.global_position = data["position"]
	asteroid.set_multiplayer_authority(1, true)

	return asteroid
