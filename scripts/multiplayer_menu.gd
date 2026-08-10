extends Control


func _ready() -> void:
	NetworkManager.connected_to_server.connect(_on_connected_to_server)
	NetworkManager.connection_failed.connect(_on_connection_failed)


func _on_host_button_pressed() -> void:
	var error = NetworkManager.host_game()

	if error != OK:
		print("Could not host game")
		return

	get_tree().change_scene_to_file(
		"res://scenes/Game.tscn"
	)


func _on_join_button_pressed() -> void:
	var error = NetworkManager.join_game("127.0.0.1")
	#var error = NetworkManager.join_game("26.82.201.159")

	if error != OK:
		print("Could not start connection")
		return

	print("Waiting for connection...")


func _on_connected_to_server() -> void:
	print("Connection successful, entering game")

	get_tree().change_scene_to_file(
		"res://scenes/Game.tscn"
	)


func _on_connection_failed() -> void:
	print("Could not connect to host")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://scenes/MainMenu.tscn"
	)
