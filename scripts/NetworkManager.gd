extends Node

signal player_connected(peer_id: int)
signal player_disconnected(peer_id: int)
signal connected_to_server
signal connection_failed

const PORT := 9999

var peer: ENetMultiplayerPeer


func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func host_game() -> Error:
	peer = ENetMultiplayerPeer.new()

	var error = peer.create_server(PORT)

	if error != OK:
		print("Failed to host: ", error)
		return error

	multiplayer.multiplayer_peer = peer
	print("Hosting game")

	return OK


func join_game(address: String) -> Error:
	peer = ENetMultiplayerPeer.new()

	var error = peer.create_client(address, PORT)

	if error != OK:
		print("Failed to join: ", error)
		return error

	multiplayer.multiplayer_peer = peer
	print("Joining ", address)

	return OK


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
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
