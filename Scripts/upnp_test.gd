extends Node2D

var multiplayer_peer = ENetMultiplayerPeer.new()

var upnp = UPNP.new()

const PORT = 9999
var ADDRESS = "localhost"

@onready var ip_node : TextEdit = $CanvasLayer/UI/SplashScreen/Menu/IP

var connected_peer_ids = []
@export var nickname : String = ""
@export var colorhex : String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var err = upnp.discover()
	
	if err != UPNP.UPNP_RESULT_SUCCESS:
		print("NO UPNP DEVICE")
		return
	
	if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
		upnp.add_port_mapping(PORT, PORT, "godot_udp", "UDP")
		upnp.add_port_mapping(PORT, PORT, "godot_tcp", "TCP")
	
	var external_ip = upnp.query_external_address()
	print("DONE! ", external_ip)
	pass # Replace with function body.

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
			upnp.delete_port_mapping(PORT, "UDP")
			upnp.delete_port_mapping(PORT, "TCP")


func _on_host_pressed() -> void:
	$CanvasLayer/UI/SplashScreen.visible = false
	nickname = $CanvasLayer/UI/SplashScreen/Menu/TextEdit.text
	colorhex = $CanvasLayer/UI/SplashScreen/ColorPicker.color.to_html(false)
	
	multiplayer_peer.create_server(PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	$CanvasLayer/UI/NetworkInfo.text = "[center]Server Network Info:\nID: " + str(multiplayer_peer.get_unique_id())
	
	add_player_character(1)
	
	multiplayer_peer.peer_connected.connect(
		func(new_peer_id):
			await get_tree().create_timer(1).timeout
			rpc("add_newly_connected_player_character", new_peer_id)
			rpc_id(new_peer_id, "add_previously_connected_player_characters", connected_peer_ids)
			
			add_player_character(new_peer_id)
			for i in connected_peer_ids:
				rpc_id(i, "share_nickname", i)
			share_nickname(1)
	)
	
	multiplayer_peer.peer_disconnected.connect(
		func(old_peer_id):
			rpc("remove_player", old_peer_id)
			remove_player(old_peer_id)
	)

func _on_join_pressed() -> void:
	$CanvasLayer/UI/SplashScreen.visible = false
	
	nickname = $CanvasLayer/UI/SplashScreen/Menu/TextEdit.text
	colorhex = $CanvasLayer/UI/SplashScreen/ColorPicker.color.to_html(false)
	var text = ip_node.text
	if text != "":
		ADDRESS = text
	
	multiplayer_peer.create_client(ADDRESS, PORT)
	
	multiplayer.multiplayer_peer = multiplayer_peer
	$CanvasLayer/UI/NetworkInfo.text = "[center]Client Network Info:\nID: " + str(multiplayer_peer.get_unique_id())
	pass # Replace with function body.

func add_player_character(peer_id):
	connected_peer_ids.append(peer_id)
	var player_character = preload("res://Scenes/player_character.tscn").instantiate()
	player_character.set_multiplayer_authority(peer_id)
	add_child(player_character)

@rpc("reliable")
func add_newly_connected_player_character(peer_id):
	add_player_character(peer_id)

@rpc("reliable")
func add_previously_connected_player_characters(peer_ids):
	for peer_id in peer_ids:
		add_player_character(peer_id)

@rpc("reliable")
func share_nickname(peer_id):
	await get_tree().create_timer(0.5).timeout
	#var nick_name = $CanvasLayer/UI/Menu/TextEdit.text
	#rpc("share_nickname_to_clients", nick_name, peer_id)
	#share_nickname_to_clients(nick_name, peer_id)
	self.get_node(str(peer_id)).update_nickname_to_clients()
	pass

@rpc("reliable")
func share_nickname_to_clients(nick : String, peer_id):
	self.get_node(str(peer_id)).set_nickname(nick)

@rpc("reliable")
func remove_player(peer_id):
	var newIDs = connected_peer_ids
	for peer in range(len(connected_peer_ids)):
		if connected_peer_ids[peer] != peer_id:
			continue
		var p_node = get_node_or_null(str(connected_peer_ids[peer]))
		if p_node == null:
			continue
		
		p_node.queue_free()
		newIDs.pop_at(peer)
		break
	connected_peer_ids = newIDs
