extends Node

@onready var ore_spawner: MultiplayerSpawner = $"../OreMultiplayerSpawner"

func _ready():
    ore_spawner.spawn_function = _spawn_ore

func spawn_ore(scene: PackedScene, position: Vector2):
    if not multiplayer.is_server():
        return

    var data = {
        "scene_path": scene.resource_path,
        "position": position
    }

    ore_spawner.spawn(data)

func _spawn_ore(data: Dictionary) -> Node:
    var scene: PackedScene = load(data["scene_path"])

    var ore = scene.instantiate()

    ore.global_position = data["position"]
    ore.set_multiplayer_authority(1, true)

    print("Ore Spawned:", ore, "at position:", ore.global_position)

    return ore
