extends Control


func _ready() -> void:
	NetworkManager.connected_to_server.connect(_on_connected_to_server)
	NetworkManager.connection_failed.connect(_on_connection_failed)
	NetworkManager.steam_lobby_created.connect(_on_steam_lobby_created)


func _on_host_button_pressed() -> void:
	var error = NetworkManager.host_enet_game()

	if error != OK:
		print("Could not host ENet game")
		return

	get_tree().change_scene_to_file(
		"res://scenes/Game.tscn"
	)


func _on_host_steam_button_pressed() -> void:
	var error = NetworkManager.host_steam_game()

	if error != OK:
		print("Could not host Steam game")
		return

	print("Creating Steam lobby...")


func _on_steam_lobby_created(lobby_id: int) -> void:
	print("Steam lobby ready: ", lobby_id)

	get_tree().change_scene_to_file(
		"res://scenes/Game.tscn"
	)


func _on_join_button_pressed() -> void:
	# var error = NetworkManager.join_enet_game("127.0.0.1")
	var error = NetworkManager.join_enet_game("192.168.1.208")

	if error != OK:
		print("Could not start connection")
		return

	print("Waiting for ENet connection...")


func _on_join_steam_button_pressed() -> void:
	var lobby_id = 109775241730935247
	var error = NetworkManager.join_steam_game(lobby_id)

	if error != OK:
		print("Could not join Steam lobby")
		return

	print("Joining Steam lobby...")


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
