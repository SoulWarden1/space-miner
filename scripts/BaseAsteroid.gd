extends RigidBody2D

@export var health := 100
@export var collision_damage := 20
@export var ore: PackedScene
@export var ore_drop_amount := 3

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

	queue_free()
