extends BaseShip
class_name PlayerShip

@export var thrust := 400.0
@export var torque := 10000.0
@export var max_speed := 500.0

func get_input() -> Vector2:
	var vertical = Input.get_axis("forward", "backward")
	var horizontal = Input.get_axis("left", "right")
	return Vector2(horizontal, vertical)

func _physics_process(delta: float) -> void:
	handle_movement()
	handle_rotation()
	
	if Input.is_action_pressed("shoot"):
		for turret in get_tree().get_nodes_in_group("Turrets"):
			turret.fire()

func handle_movement() -> void:
	var direction = get_input()
	
	if direction.length() != 0:
		apply_central_force(direction.rotated(rotation) * thrust)

func handle_rotation() -> void:
	var rotate_input = Input.get_axis(
		"rotate_left",
		"rotate_right"
	)

	apply_torque(
		rotate_input * torque
	)
	
func _integrate_forces(state):
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
