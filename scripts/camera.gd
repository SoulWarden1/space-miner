extends Camera2D

var target: PlayerShip
@export var target_size := 150.0

func set_target(ship):
	target = ship
	var sprite = ship.get_node("Sprite2D")
	var size = sprite.texture.get_size() * sprite.scale
	var max_dimension = max(size.x, size.y)
	var zoom_amount = target_size / max_dimension
	zoom = Vector2(zoom_amount, zoom_amount)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target:
		global_position = target.global_position
		global_rotation = target.global_rotation
