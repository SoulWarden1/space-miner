extends BaseComponent

signal boost_updated(boost_fuel, max_boost_fuel)

## What multiplier to apply to the ship thrust
@export var boost_factor: float = 2.0
## Boost fuel
@export var max_boost_fuel: float = 400
## Time before boost_factor starts to refill
@export var boost_cooldown_time: float = 3.0
## Boost refill amount per second
@export var boost_regenerate_rate: float = 5.0

@onready var cooldown: Timer = $Cooldown
var is_cooling_down := false
var boost_fuel = 0.0

func _ready() -> void:
    cooldown.wait_time = boost_cooldown_time
    boost_fuel = max_boost_fuel

func get_boost() -> float:
    var boost_input = Input.is_action_pressed("boost_factor")

    # If the boost_factor button is pressed, reset the cooldown
    if boost_input:
        is_cooling_down = true
        cooldown.start()

        # If there is fuel then boost_factor
        if boost_fuel > 0:
            boost_fuel = max(0, boost_fuel - 1)

            boost_updated.emit(boost_fuel, max_boost_fuel)
            print(boost_fuel, "/", max_boost_fuel)
            return boost_factor

    return 1


func _on_cooldown_timeout() -> void:
    is_cooling_down = false

func _process(delta: float) -> void:
    if not multiplayer.is_server():
        return

    if not is_cooling_down and boost_fuel < max_boost_fuel:
        boost_fuel += boost_regenerate_rate * delta
        boost_fuel = min(boost_fuel, max_boost_fuel)
        print(boost_fuel, "/", max_boost_fuel)
        boost_updated.emit(boost_fuel, max_boost_fuel)
