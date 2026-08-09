extends RigidBody2D

@export var health := 100
@export var collision_damage := 20
@export var ore: PackedScene
@export var ore_drop_amount := 3

func take_damage(amount: int) -> void:
	health -= amount
	
	if health <= 0:
		destroy()
		
func get_collision_damage() -> int:
	return collision_damage

func destroy() -> void:
	queue_free()
