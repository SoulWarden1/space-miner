extends Node
class_name ShieldComponent

signal shield_updated(current_shield, max_shield)

@onready var cooldown: Timer = $Cooldown

## The time before the shield starts to recharge
@export var shield_cooldown_time: float = 3.0
## The amount of shield regenerated per second
@export var shield_regenerate_rate: float = 5.0
## The maximum amount of shield
@export var max_shield: float = 100.0

var shield: float = 0.0
var is_cooling_down := false

func _ready() -> void:
	shield = max_shield
	cooldown.wait_time = shield_cooldown_time

func absorb_damage(amount: int) -> int:
	if not multiplayer.is_server():
		return amount

	shield -= amount
	is_cooling_down = true
	cooldown.start()

	if shield < 0:
		var remaining_damage = int(-shield)
		shield = 0

		shield_updated.emit(shield, max_shield)

		print("Shield depleted. Remaining damage: ", remaining_damage)
		return remaining_damage

	shield_updated.emit(shield, max_shield)

	print("Shield absorbed damage. Remaining shield: ", shield)
	return 0


func _on_cooldown_timeout() -> void:
	is_cooling_down = false


func _process(delta: float) -> void:
	if not multiplayer.is_server():
		return

	if not is_cooling_down and shield < max_shield:
		shield += shield_regenerate_rate * delta
		shield = min(shield, max_shield)

		shield_updated.emit(shield, max_shield)