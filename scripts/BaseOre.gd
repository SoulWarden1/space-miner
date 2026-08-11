extends Area2D
class_name BaseOre

var ore_type: OreTypes.Type
var ore_amount: int = 1

func _on_body_entered(body: Node2D) -> void:
    print("Ore collided with: ", body.name)
    if multiplayer.is_server() and body.has_method("collect_ore"):
        print("Collecting ore of type: ", ore_type, " with amount: ", ore_amount)
        body.collect_ore(ore_type, ore_amount)
        queue_free()
