extends Node2D
class_name BaseWeapon

@export var projectile_scene: PackedScene
## The fire rate per second
@export var fire_rate := 1.0
var muzzles: Array[Marker2D]

var can_fire := true

func _ready() -> void:
	# Gets all children of type market2d, which are the muzzles
	for child in get_children():
		if child is Marker2D:
			muzzles.append(child)
	
func fire():
	push_error("Weapon does not have a fire method implemented!")
