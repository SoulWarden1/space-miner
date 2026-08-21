extends BaseShip
class_name PlayerShip

@export var thrust := 400.0
@export var torque := 10000.0
@export var max_speed := 500.0
var inventory := {}
@onready var boost_component: BaseModule = get_node_or_null("Modules/BoostComponent")


func get_input() -> Vector2:
	var vertical = Input.get_axis("forward", "backward")
	var horizontal = Input.get_axis("left", "right")
	return Vector2(horizontal, vertical)

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return

	handle_movement()
	handle_rotation()

	if Input.is_action_pressed("shoot"):
		for turret in get_tree().get_nodes_in_group("Weapons"):
			turret.fire()

func handle_movement() -> void:
	var direction = get_input()

	if direction.length() != 0:
		var boost
		if boost_component:
			boost = boost_component.get_boost()
		else:
			boost = 1

		apply_central_force(direction.rotated(rotation) * thrust * boost)

func handle_rotation() -> void:
	var rotate_input = Input.get_axis(
		"rotate_left",
		"rotate_right"
	)

	apply_torque(
		rotate_input * torque
	)

func _integrate_forces(state):
	# Limit the speed of the ship to max_speed
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed

func collect_ore(ore_type: OreTypes.Type, amount: int) -> void:
	if not multiplayer.is_server():
		return

	inventory[ore_type] = inventory.get(ore_type, 0) + amount
	print(inventory)

	sync_inventory.rpc(
		ore_type,
		inventory[ore_type]
	)

@rpc("any_peer", "call_remote", "reliable")
func sync_inventory(ore_type: OreTypes.Type, amount: int):
	if multiplayer.get_remote_sender_id() != 1 and not multiplayer.is_server():
		return

	inventory[ore_type] = amount

func dock():
	print("Player ship docking")
	pass
