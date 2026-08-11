extends Area2D
class_name BaseProjectile

@export var speed := 800.0
@export var damage := 10
@export var lifetime := 3.0
@export var mass := 0.2
var shooter_peer_id: int = -1

var direction := Vector2.UP

func _ready():
	await get_tree().create_timer(lifetime).timeout
	destroy()

func _physics_process(delta):
	global_position += direction * speed * delta

func destroy():
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if not multiplayer.is_server():
		return

	if body.has_method("take_damage"):
		body.take_damage(damage)

	if body is RigidBody2D:
		var impulse = direction * speed * mass
		body.apply_impulse(impulse)

	destroy()
