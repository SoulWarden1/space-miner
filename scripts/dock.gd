extends Area2D
class_name Dock

signal docked(dock: Dock, ship: PlayerShip)

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerShip:
		docked.emit(self, body)