extends CanvasLayer

@onready var health_bar: ProgressBar = $VBoxContainer/HealthBar
@onready var health_label: Label = $VBoxContainer/HealthBar/HealthLabel
@onready var shield_bar: ProgressBar = $VBoxContainer/ShieldBar
@onready var shield_label: Label = $VBoxContainer/ShieldBar/ShieldLabel
var shield_exists: bool = false

func _ready() -> void:
	call_deferred("_setup_player")

## Attempts to find the local player and connect to its health_changed signal.
func _setup_player() -> void:
	var game_manager = get_tree().current_scene.get_node("GameManager")

	if game_manager.local_player == null:
		await get_tree().process_frame
		_setup_player()
		return

	var player: BaseShip = game_manager.local_player

	if player.get_shield():
		show_shield_hud()
	else:
		hide_shield_hud()

	player.health_changed.connect(_on_health_changed)

	# Initialise HUD immediately.
	_on_health_changed(
		player.health,
		player.max_health,
		player.shield.shield if player.shield else 0.0,
		player.shield.max_shield if player.shield else 0.0
	)

func _on_health_changed(
	current_health: int,
	max_health: int,
	current_shield: float,
	max_shield: float
) -> void:
	update_health(current_health, max_health)

	if max_shield > 0:
		update_shield(current_shield, max_shield)
		show_shield_hud()
	else:
		hide_shield_hud()

func update_health(current_health: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = current_health
	health_label.text = str(current_health, " / ", max_health)

func update_shield(current_shield: float, max_shield: float) -> void:
	shield_bar.max_value = max_shield
	shield_bar.value = current_shield
	shield_label.text = str(int(current_shield), " / ", int(max_shield))

func show_shield_hud() -> void:
	shield_bar.visible = true
	shield_label.visible = true

func hide_shield_hud() -> void:
	shield_bar.visible = false
	shield_label.visible = false