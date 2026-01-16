extends Node

enum broadcast_msg {
	id,
	join,
	userConnected,
	userDisconnected,
	lobby,
	candidate,
	offer,
	answer,
	checkIn
}

var cmd_args = {}

func _ready():
	for cmdline in OS.get_cmdline_args():
			if cmdline.contains("="):
				var key_value = cmdline.split("=")
				cmd_args[key_value[0].trim_prefix("--")] = key_value[1]
			else:
				# Options without an argument will be present in the dictionary,
				# with the value set to an empty string.
				cmd_args[cmdline.trim_prefix("--")] = ""
	if "brc_dedicate" in cmd_args:
		start_server()
	peer.peer_connected.connect(peer_connected)
	peer.peer_disconnected.connect(peer_disconnected)
	

var peer = WebSocketMultiplayerPeer.new()
var users = {}
var lobbies = {}

const chara_list = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

func _process(_delta):
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var datstr = packet.get_string_from_utf8()
			var data = JSON.parse_string(datstr)
			print("----------------------------------")
			print("Server: ",data)
			
			if data.msg == broadcast_msg.lobby:
				join_lobby(data)
			
			if int(data.msg) in [broadcast_msg.offer,broadcast_msg.answer,broadcast_msg.candidate]: #[6.0,7.0,5.0]
				print("Server: Soruce ID is ",data.org_peer)#," Messge data ", data.data)
				msg_peer_data(data.peer,data)

func start_server():
	$"../ServerButton".disabled = true
	$"../test2".disabled = false
	peer.create_server(8915)
	print("Server: Start server")

func join_lobby(user):
	#var result = ""
	if user.lobby_value == "":
		user.lobby_value = gen_rand_str()
		lobbies[user.lobby_value] = brc_testing_lobby.new(user.id)
		print("Server: ",user.lobby_value)
	@warning_ignore("unused_variable")
	var player = lobbies[user.lobby_value].add_player(user.id,user.name)
	
	for p in lobbies[user.lobby_value].players:
		
		var _data = {
			"msg": broadcast_msg.userConnected,
			"id": user.id
		}
		msg_peer_data(p,_data)
		
		var data2 = {
			"msg": broadcast_msg.userConnected,
			"id": user.id
		}
		msg_peer_data(user.id,data2)
		
		var lobby_info = {
			"msg":broadcast_msg.lobby,
			"player_list":JSON.stringify(lobbies[user.lobby_value].players),
			"host":lobbies[user.lobby_value].host_id,
			"lobby_value": user.lobby_value
		}
		msg_peer_data(p, lobby_info)
	
	var data = {
		"msg": broadcast_msg.userConnected,
		"id":user.id,
		"player":lobbies[user.lobby_value].players[user.id]
	}
	msg_peer_data(data.id,data)

func msg_peer_data(user_id,msg):
	peer.get_peer(user_id).put_packet(JSON.stringify(msg).to_utf8_buffer())

func gen_rand_str() -> String:
	var result = ""
	for i in range(32):
		var rand_index = randi() % chara_list.length()
		result += chara_list[rand_index]
	return result

func peer_connected(id):
	print("Server: Peer Connected: ", id)
	users[id] = {
		"id": id,
		"msg": broadcast_msg.id
	}
	msg_peer_data(id,users[id])
	pass

func peer_disconnected(id):
	print("Server: Peer Disconnected: ", id)
	pass

func _on_server_button_button_down():
	start_server()


func _on_test_button_down():
	var msg = {
		"msg":broadcast_msg.checkIn,
		"data": "Test"
	}
	peer.put_packet(JSON.stringify(msg).to_utf8_buffer())
	pass # Replace with function body.
