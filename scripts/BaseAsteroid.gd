extends SpaceBody
class_name BaseAsteroid

@export var ore_scene: PackedScene
@export var ore_min_drop_amount := 1
@export var ore_max_drop_amount := 3
@export var explosion_scene: PackedScene

@onready var particles: GPUParticles2D = $GPUParticles2D

func _ready() -> void:
	super._ready()
	if multiplayer.has_multiplayer_peer() and not multiplayer.is_server():
		freeze = true


func destroy() -> void:
	super.destroy()
	drop_ores()

	if multiplayer.is_server():
		print("Spawning explosion")
		spawn_explosion.rpc(global_position)


func drop_ores() -> void:
	if ore_scene == null:
		return

	var amount = randi_range(
		ore_min_drop_amount,
		ore_max_drop_amount
	)

	var ore_manager = get_tree().current_scene.get_node(
		"OreManager"
	)

	for i in amount:
		var offset = Vector2(
			randf_range(-40.0, 40.0),
			randf_range(-40.0, 40.0)
		)

		print("Dropping ore at position: ", global_position + offset)
		ore_manager.spawn_ore(
			ore_scene,
			global_position + offset
		)

@rpc("authority", "call_local", "unreliable")
func spawn_explosion(explosion_position: Vector2) -> void:
	if explosion_scene == null:
		return

	var explosion = explosion_scene.instantiate()
	explosion.global_position = explosion_position
	get_tree().current_scene.add_child(explosion)


