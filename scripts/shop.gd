extends Control

var current_ship: PlayerShip
@export var empty_slot_scene: PackedScene

func _ready() -> void:
	visible = false

func open_for_ship(ship: PlayerShip) -> void:
	current_ship = ship
	visible = true

	refresh_component_list()


func close_menu() -> void:
	current_ship = null
	visible = false

func refresh_component_list():
	pass