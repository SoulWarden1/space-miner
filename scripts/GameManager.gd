extends Node
@onready var health_bar: ProgressBar = $"../HUD/HealthBar"
@onready var health_label: Label = $"../HUD/HealthLabel"
@onready var camera: Camera2D = $"../Camera2D"

var player_ship: PlayerShip

func _ready():
	for node in get_tree().get_nodes_in_group("PlayerShip"):
		if node is PlayerShip:
			player_ship = node
			camera.set_target(player_ship)
			break
	
	player_ship.health_changed.connect(update_health)
	update_health(
		player_ship.health,
		player_ship.max_health
	)
	
func update_health(current: int, maximum: int):
	health_bar.max_value = maximum
	health_bar.value = current
	
	health_label.text = str(current)
	
	
