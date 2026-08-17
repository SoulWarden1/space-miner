extends Camera2D

var _target: PlayerShip
@export var target_size := 150.0

func set_target(ship):
	_target = ship
	# Set initial camera position so the lerp doesn't smooth the movement on spawning
	global_position = _target.global_position
	global_rotation = _target.global_rotation

	# Set the zoom of the camera dynamically depending on the sprite size
	var sprite = ship.get_node("Sprite2D")
	var size = sprite.texture.get_size() * sprite.scale
	var max_dimension = max(size.x, size.y)
	var zoom_amount = target_size / max_dimension
	zoom = Vector2(zoom_amount, zoom_amount)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _target:
		global_position = global_position.lerp(
			_target.global_position,
			5.0 * delta
		)
		global_rotation = _target.global_rotation
