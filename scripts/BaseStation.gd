extends SpaceBody
class_name BaseStation

var docks: Array[Dock] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_node("Docks").get_children():
		if child is Dock:
			docks.append(child)
			child.docked.connect(player_docked)

func get_docks() -> Array[Dock]:
	return docks


func player_docked(dock: Dock, ship: PlayerShip) -> void:
	print("Player ", ship.name, " docked to ", dock.name)

	if ship.has_method("dock"):
		ship.dock()
