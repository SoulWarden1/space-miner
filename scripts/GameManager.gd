extends Node
@onready var health_bar: ProgressBar = $"../HUD/HealthBar"
@onready var shield_bar: ProgressBar = $"../HUD/ShieldBar"
@onready var health_label: Label = $"../HUD/HealthLabel"
@onready var camera: Camera2D = $"../Camera2D"

var player_ship: PlayerShip

func _ready():
	for node in get_tree().get_nodes_in_group("PlayerShip"):
		if node is PlayerShip:
			player_ship = node
			camera.set_target(player_ship)
			break
			
	# Checks if a player ship was found		
	if not player_ship:
		push_error("No player ship detected.")
	
	player_ship.health_changed.connect(update_health)
	
	if player_ship.get_shield() != null:
		update_health(
			player_ship.health,
			player_ship.max_health,
			player_ship.shield.shield,
			player_ship.shield.max_shield
		)
	else:
		update_health(
			player_ship.health,
			player_ship.max_health,
			0,
			0
		)
	
func update_health(health: int, max_health: int, shield: int, max_shield: int):
	shield_bar.visible = true if max_shield != 0 else false
	health_bar.max_value = max_health
	health_bar.value = health
	
	health_label.text = str(health)
	
	shield_bar.max_value = max_shield
	shield_bar.value = shield
	
	
	
