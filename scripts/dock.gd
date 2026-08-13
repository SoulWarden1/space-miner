extends Area2D
class_name Dock

signal docked(ship: PlayerShip)

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerShip:
		docked.emit(body)