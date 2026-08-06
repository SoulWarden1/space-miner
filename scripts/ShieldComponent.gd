# ShieldComponent.gd
extends Node
class_name ShieldComponent

@export var max_shield := 100

var shield: int

func _ready():
	shield = max_shield

func absorb_damage(amount: int) -> int:
	shield -= amount

	if shield < 0:
		var remaining_damage = -shield
		shield = 0
		return remaining_damage
	return 0
