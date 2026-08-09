extends Control

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
	

func _on_multiplayer_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MultiplayerMenu.tscn")
	

func _on_options_button_pressed() -> void:
	print("Options")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
