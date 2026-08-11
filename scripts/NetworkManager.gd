extends Node

signal player_connected(peer_id: int)
signal player_disconnected(peer_id: int)
signal connected_to_server
signal connection_failed
signal steam_lobby_created(lobby_id: int)


const PORT := 9999
const MAX_CLIENTS := 4

enum NetworkType {
	NONE,
	ENET,
	STEAM
}

var network_type := NetworkType.NONE

var enet_peer: ENetMultiplayerPeer
var steam_peer: SteamMultiplayerPeer

var steam_enabled := false
var steam_lobby_id: int = 0


func _ready() -> void:
	initialize_steam()

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

	if steam_enabled:
		Steam.lobby_created.connect(_on_lobby_created)
		Steam.lobby_joined.connect(_on_lobby_joined)
		Steam.join_requested.connect(_on_lobby_join_requested)


func _process(_delta: float) -> void:
	if steam_enabled:
		Steam.run_callbacks()


func initialize_steam() -> void:
	var initialize_response: Dictionary = Steam.steamInitEx()

	print("Did Steam initialize?: ", initialize_response)

	if initialize_response["status"] > Steam.STEAM_API_INIT_RESULT_OK:
		print(
			"Failed to initialize Steam: ",
			initialize_response
		)

		steam_enabled = false
		return

	steam_enabled = true


func host_enet_game() -> Error:
	network_type = NetworkType.ENET

	enet_peer = ENetMultiplayerPeer.new()

	var error = enet_peer.create_server(
		PORT,
		MAX_CLIENTS
	)

	if error != OK:
		print("Failed to host ENet game: ", error)
		network_type = NetworkType.NONE
		return error

	multiplayer.multiplayer_peer = enet_peer

	print("Hosting ENet game")

	return OK

func host_steam_game() -> Error:
	if not steam_enabled:
		print("Steam is not available")
		return ERR_UNAVAILABLE

	network_type = NetworkType.STEAM

	Steam.createLobby(
		Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY,
		MAX_CLIENTS
	)

	return OK



func join_enet_game(address: String) -> Error:
	network_type = NetworkType.ENET

	enet_peer = ENetMultiplayerPeer.new()

	var error = enet_peer.create_client(
		address,
		PORT
	)

	if error != OK:
		print("Failed to join ENet game: ", error)
		network_type = NetworkType.NONE
		return error

	multiplayer.multiplayer_peer = enet_peer

	print("Joining ENet host ", address)

	return OK

func join_steam_game(lobby_id: int) -> Error:
	if not steam_enabled:
		return ERR_UNAVAILABLE

	network_type = NetworkType.STEAM
	steam_lobby_id = lobby_id

	Steam.joinLobby(lobby_id)

	return OK

func _on_lobby_join_requested(
	lobby_id: int,
	friend_id: int
) -> void:
	print("Steam Join Game requested")
	print("Lobby ID: ", lobby_id)
	print("Friend ID: ", friend_id)

	join_steam_game(lobby_id)


func _on_peer_connected(peer_id: int):
	print("NETWORK MANAGER: peer connected ", peer_id)
	player_connected.emit(peer_id)


func _on_peer_disconnected(peer_id: int):
	print("NETWORK MANAGER: peer disconnected ", peer_id)
	player_disconnected.emit(peer_id)

func _on_connected_to_server() -> void:
	print("CONNECTED TO SERVER")
	print("My peer ID: ", multiplayer.get_unique_id())
	connected_to_server.emit()


func _on_connection_failed() -> void:
	print("CONNECTION FAILED")
	connection_failed.emit()


func _on_server_disconnected() -> void:
	print("SERVER DISCONNECTED")
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_lobby_created(connect: int, lobby_id: int) -> void:
	print("LOBBY CREATED CALLBACK")
	print("Result: ", connect)
	print("Lobby ID: ", lobby_id)

	if connect != Steam.RESULT_OK:
		print("Failed to create Steam lobby")
		return

	steam_lobby_id = lobby_id

	Steam.setLobbyData(
		lobby_id,
		"name",
		Steam.getPersonaName() + "'s Lobby"
	)

	Steam.setLobbyData(
		lobby_id,
		"game_started",
		"false"
	)

	steam_peer = SteamMultiplayerPeer.new()

	var error = steam_peer.create_host()

	print("create_host result: ", error)

	if error != OK:
		return

	multiplayer.multiplayer_peer = steam_peer

	print("STEAM HOST READY")
	print("Godot peer ID: ", multiplayer.get_unique_id())

	steam_lobby_created.emit(lobby_id)


func _on_lobby_joined(
	lobby_id: int,
	_permissions: int,
	_locked: bool,
	response: int
) -> void:
	print("LOBBY JOINED CALLBACK")
	print("Lobby ID: ", lobby_id)
	print("Response: ", response)

	if response != Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		print("Failed to join Steam lobby")
		return

	var host_steam_id = Steam.getLobbyOwner(lobby_id)
	var my_steam_id = Steam.getSteamID()

	print("Host Steam ID: ", host_steam_id)
	print("My Steam ID: ", my_steam_id)

	# The host also "joins" its own lobby.
	# Don't create a client connection to yourself.
	if host_steam_id == my_steam_id:
		print("I am the lobby host, skipping create_client")
		return

	steam_peer = SteamMultiplayerPeer.new()

	var error = steam_peer.create_client(host_steam_id)

	print("create_client result: ", error)

	if error != OK:
		print("Failed to create Steam client")
		return

	multiplayer.multiplayer_peer = steam_peer

	print("Waiting for Steam multiplayer connection...")

func open_invite_menu() -> void:
	if steam_lobby_id == 0:
		return

	Steam.activateGameOverlayInviteDialog(
		steam_lobby_id
	)