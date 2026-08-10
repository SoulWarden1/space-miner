extends Node

@onready var projectile_spawner: MultiplayerSpawner = $"../ProjectileMultiplayerSpawner"


func _ready():
	projectile_spawner.spawn_function = _spawn_projectile


func spawn_projectile(
	scene: PackedScene,
	position: Vector2,
	rotation: float,
	shooter_peer_id: int
):
	if not multiplayer.is_server():
		return

	var data = {
		"scene_path": scene.resource_path,
		"position": position,
		"rotation": rotation,
		"shooter_peer_id": shooter_peer_id
	}

	projectile_spawner.spawn(data)


func _spawn_projectile(data: Dictionary) -> Node:
	var scene: PackedScene = load(data["scene_path"])

	var projectile = scene.instantiate()

	projectile.global_position = data["position"]
	projectile.global_rotation = data["rotation"]

	projectile.direction = Vector2.UP.rotated(
		data["rotation"]
	)

	projectile.shooter_peer_id = data["shooter_peer_id"]

	return projectile
