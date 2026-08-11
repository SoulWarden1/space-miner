extends RigidBody2D

@export var health := 100
@export var collision_damage := 20
@export var ore_scene: PackedScene
@export var ore_min_drop_amount := 1
@export var ore_max_drop_amount := 3

func _ready() -> void:
	if multiplayer.has_multiplayer_peer() and not multiplayer.is_server():
		freeze = true

func take_damage(amount: int) -> void:
	if not multiplayer.is_server():
		return

	health -= amount

	if health <= 0:
		destroy()

func get_collision_damage() -> int:
	return collision_damage

func destroy() -> void:
	if not multiplayer.is_server():
		return

	drop_ores()
	queue_free()

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
