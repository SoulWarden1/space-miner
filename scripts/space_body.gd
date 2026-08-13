extends RigidBody2D
class_name SpaceBody


signal health_changed(
	current_health,
	max_health,
	current_shield,
	max_shield
)

@export var max_health: int = 100
@export var collision_damage := 20
var health: int
var collision_cooldown := false
@export var can_take_collision_damage := true

@onready var shield: ShieldComponent = get_node_or_null(
	"ShieldComponent"
)

func _ready():
	health = max_health

	if shield:
		shield.shield_updated.connect(shield_regenerated)

	emit_health_state()


func take_damage(amount: int) -> void:
	if not multiplayer.is_server():
		return

	if shield:
		amount = shield.absorb_damage(amount)

	health -= amount
	health = max(health, 0)

	sync_health_state.rpc(
		health,
		shield.shield if shield else 0.0
	)

	if health <= 0:
		destroy()


func heal(amount: int) -> void:
	if not multiplayer.is_server():
		return

	health = clamp(
		health + amount,
		0,
		max_health
	)

	sync_health_state.rpc(
		health,
		shield.shield if shield else 0.0
	)


func shield_regenerated(
	current_shield: float,
	maximum_shield: float
):
	if not multiplayer.is_server():
		return

	sync_health_state.rpc(
		health,
		current_shield
	)


@rpc("any_peer", "call_local", "reliable")
func sync_health_state(
	new_health: int,
	new_shield: float
) -> void:
	if multiplayer.get_remote_sender_id() != 1 and not multiplayer.is_server():
		return

	health = new_health

	if shield:
		shield.shield = new_shield

	emit_health_state()


func emit_health_state() -> void:
	health_changed.emit(
		health,
		max_health,
		shield.shield if shield else 0.0,
		shield.max_shield if shield else 0.0
	)


func destroy() -> void:
	if not multiplayer.is_server():
		return

	queue_free()


func get_shield():
	return shield

func get_collision_damage() -> int:
	return collision_damage


func _on_body_entered(body: Node) -> void:
	print("Collision detected with: ", body.name)
	if not multiplayer.is_server():
		return

	if not can_take_collision_damage:
		return

	if collision_cooldown:
		return

	if body.has_method("get_collision_damage"):
		var impact_speed = linear_velocity.length()

		var damage = int(
			body.get_collision_damage()
			+ (impact_speed / 5)
			+ (body.mass / 20)
		)

		take_damage(damage)

		print("Total Damage taken: ", damage)
		print("Speed Damage: ", impact_speed / 5)
		print("Mass Damage: ", body.mass / 20)

		collision_cooldown = true

		await get_tree().create_timer(0.5).timeout

		collision_cooldown = false
