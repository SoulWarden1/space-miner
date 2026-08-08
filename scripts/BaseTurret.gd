extends BaseWeapon
class_name BaseTurret

## The rotation speed of the turret in radians per second
@export var rotate_speed: float = 4.0

func _process(delta: float) -> void:
	var target_angle = global_position.angle_to_point(
		get_global_mouse_position()
	) + (PI / 2)
	
	global_rotation = rotate_toward(global_rotation, target_angle, rotate_speed * delta)
	
func fire():
	if !can_fire:
		return
	
	for muzzle in muzzles:
		fire_from_muzzle(muzzle)
		can_fire = false
		await get_tree().create_timer(1.0 / fire_rate / len(muzzles)).timeout
		can_fire = true
	
func fire_from_muzzle(muzzle: Marker2D):
	var bullet = projectile_scene.instantiate()

	bullet.global_position = muzzle.global_position
	bullet.global_rotation = global_rotation
	bullet.direction = Vector2.UP.rotated(global_rotation)

	get_tree().current_scene.add_child(bullet)
