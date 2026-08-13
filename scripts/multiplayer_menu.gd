extends Control

@onready var server_popup = $ServerPopup
@onready var server_ip_input = $ServerPopup/ServerIPInput


func _ready() -> void:
	server_popup.confirmed.connect(_on_server_popup_confirmed)
	server_ip_input.text_submitted.connect(func(_text): server_popup.confirmed.emit())

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
	# var error = NetworkManager.join_enet_game("192.168.1.208")
	# var error = NetworkManager.join_enet_game("118.138.42.157")

	# if error != OK:
	# 	print("Could not start connection")
	# 	return

	# print("Waiting for ENet connection...")

	show_server_input_popup()

func show_server_input_popup() -> void:
	server_ip_input.clear()
	server_ip_input.placeholder_text = "Enter IP Address..."
	server_popup.popup_centered()

func show_steam_input_popup() -> void:
	server_ip_input.clear()
	server_ip_input.placeholder_text = "Enter Steam Lobby ID..."
	server_popup.popup_centered()

func _on_server_popup_confirmed() -> void:
	var error: Error
	var isSteam := false
	var regex = RegEx.new()
	# Checks if the input is a valid IPv4 address
	regex.compile(r"^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$")

	var server_ip = server_ip_input.text

	if regex.search(server_ip) != null:
		error = NetworkManager.join_enet_game(server_ip)
		isSteam = false
		print("Valid IPv4 address: ", server_ip, " Attempting to join ENet game...")
	elif server_ip.length() >= 15 and server_ip.is_valid_int():
		print("Valid Steam Lobby ID: ", server_ip, " Attempting to join Steam game...")
		isSteam = true
		error = NetworkManager.join_steam_game(int(server_ip))
	else:
		print("Invalid input, must be a valid IPv4 address or a 20-digit Steam lobby ID")
		return

	if error != OK:
		print("Could not start connection")
		return


func _on_join_steam_button_pressed() -> void:
	# var lobby_id = 109775241849299689
	# var error = NetworkManager.join_steam_game(lobby_id)

	# if error != OK:
	# 	print("Could not join Steam lobby")
	# 	return

	# print("Joining Steam lobby...")
	show_steam_input_popup()


func _on_connected_to_server() -> void:
	if NetworkManager.network_type == NetworkManager.NetworkType.ENET:
		get_tree().change_scene_to_file(
			"res://scenes/Game.tscn"
		)


func _on_connection_failed() -> void:
	print("Could not connect to host")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://scenes/MainMenu.tscn"
	)
