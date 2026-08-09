## A base cannon, which is a weapon which cannot rotate
extends BaseWeapon
class_name BaseCannon

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
