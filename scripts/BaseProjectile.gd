extends Area2D
class_name BaseProjectile

@export var speed := 800.0
@export var damage := 10
@export var lifetime := 3.0

var direction := Vector2.UP

func _ready():
	await get_tree().create_timer(lifetime).timeout
	destroy()


func _physics_process(delta):
	global_position += direction * speed * delta

func destroy():
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage)

	destroy()
