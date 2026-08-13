extends SpaceBody

var docks: Array[Dock] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is Dock:
			docks.append(child)
			child.docked.connect(player_docked)


func player_docked(ship: PlayerShip) -> void:
	print("Player docked: ", ship.name)
