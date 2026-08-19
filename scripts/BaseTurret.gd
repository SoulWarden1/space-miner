extends BaseWeapon
class_name BaseTurret

## The rotation speed of the turret in radians per second
@export var rotate_speed: float = 4.0

func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return

	var target_angle = global_position.angle_to_point(
		get_global_mouse_position()
	) + (PI / 2)

	global_rotation = rotate_toward(
		global_rotation,
		target_angle,
		rotate_speed * delta
	)


func fire():
	if not is_multiplayer_authority():
		return

	if not can_fire:
		return

	if multiplayer.is_server():
		request_fire()
	else:
		request_fire.rpc_id(1)


@rpc("any_peer", "call_remote", "reliable")
func request_fire():
	if not multiplayer.is_server():
		return

	var sender_id = multiplayer.get_remote_sender_id()

	# If the server called this RPC on itself
	if sender_id == 0:
		sender_id = multiplayer.get_unique_id()

	if sender_id != get_multiplayer_authority():
		return

	if not can_fire:
		return

	can_fire = false

	for muzzle in muzzles:
		_fire_from_muzzle(muzzle)

		await get_tree().create_timer(
			1.0 / fire_rate / muzzles.size()
		).timeout

	can_fire = true


func _fire_from_muzzle(muzzle: Marker2D):
	var projectile_manager = get_tree().current_scene.get_node(
		"ProjectileManager"
	)

	var projectile_deviation = randf_range(-spread, spread)

	projectile_manager.spawn_projectile(
		projectile_scene,
		muzzle.global_position,
		global_rotation + deg_to_rad(projectile_deviation),
		get_multiplayer_authority()
	)

	weapon_sound_player.play()
