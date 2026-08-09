extends RigidBody2D
class_name BaseShip

signal health_changed(current_health, max_health, current_shield, max_shield)

@export var max_health: int
var health: int

var collision_cooldown := false
@onready var shield: ShieldComponent = get_node_or_null("ShieldComponent")

func _ready():
	if shield:
		shield.shield_updated.connect(shield_regenerated)

	health = max_health

	if multiplayer.is_server():
		health_changed.emit(
			health,
			max_health,
			shield.shield if shield else 0,
			shield.max_shield if shield else 0
		)
		
func take_damage(amount: int) -> void:
	if not multiplayer.is_server():
		return

	if shield:
		amount = shield.absorb_damage(amount)

	health -= amount
	health = max(health, 0)

	health_changed.emit(
		health,
		max_health,
		shield.shield if shield else 0,
		shield.max_shield if shield else 0
	)

	if health <= 0:
		destroy()

func heal(amount: int) -> void:
	health = clamp(health + amount, 0, max_health)
	
func shield_regenerated(current_shield, maximum_shield):
	health_changed.emit(health, max_health, current_shield, maximum_shield)

func destroy() -> void:
	queue_free()
	
func get_shield():
	return shield
	
func _on_body_entered(body: Node) -> void:
	if not multiplayer.is_server():
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
