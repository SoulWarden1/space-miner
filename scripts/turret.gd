extends Node2D
class_name Turret

@onready var muzzle: Marker2D = $Muzzle
@export var projectile_scene: PackedScene
@export var fire_rate := 5.0

var can_fire := true

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	rotation += PI / 2
	
func fire():
	if !can_fire:
		return

	var bullet = projectile_scene.instantiate()

	bullet.global_position = muzzle.global_position
	bullet.global_rotation = global_rotation
	bullet.direction = Vector2.UP.rotated(global_rotation)

	get_tree().current_scene.add_child(bullet)

	can_fire = false
	await get_tree().create_timer(1.0 / fire_rate).timeout
	can_fire = true
