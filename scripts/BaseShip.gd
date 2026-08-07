extends RigidBody2D
class_name BaseShip

signal health_changed(current_health, max_health)

@export var max_health: int
var health: int

var collision_cooldown := false

@onready var shield = get_node_or_null("ShieldComponent")

func _ready():
	health = max_health
	health_changed.emit(health, max_health)

func take_damage(amount: int) -> void:
	if shield:
		amount = shield.absorb_damage(amount)
		
	health -= amount
	health = max(health, 0)
	
	health_changed.emit(health, max_health)
	
	if health <= 0:
		destroy()

func heal(amount: int) -> void:
	health = clamp(health + amount, 0, max_health)

func destroy() -> void:
	queue_free()
	
func _on_body_entered(body: Node) -> void:
	if collision_cooldown:
		return
		
	if body.has_method("get_collision_damage"):
		var impact_speed = linear_velocity.length()
		var damage = int(body.get_collision_damage() + (impact_speed / 5) + (body.mass / 20))
		take_damage(damage)
		print("Total Damage taken: " + str(damage))
		print("Speed Damage: " + str(impact_speed / 5))
		print("Mass Damage: " + str((body.mass / 20)))
		
	collision_cooldown = true
	await get_tree().create_timer(0.5).timeout
	collision_cooldown = false
