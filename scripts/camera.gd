extends Camera2D

var _target: Node
@export var target_size := 150.0

func set_target(target):
	_target = target
	global_position = _target.global_position

	if _target is BaseShip:
		# Set initial camera position so the lerp doesn't smooth the movement on spawning
		global_rotation = _target.global_rotation

		# Set the zoom of the camera dynamically depending on the sprite size
		var sprite = target.get_node("Sprite2D")
		var size = sprite.texture.get_size() * sprite.scale
		var max_dimension = max(size.x, size.y)
		var zoom_amount = target_size / max_dimension
		zoom = Vector2(zoom_amount, zoom_amount)
	else:
		global_rotation = 0
		zoom = Vector2(1,1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not _target:
		return

	if _target is BaseShip:
		global_position = global_position.lerp(
			_target.global_position,
			5.0 * delta
		)
		global_rotation = _target.global_rotation
