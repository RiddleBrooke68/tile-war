## @experimental
extends Node
class_name brc_testing_server

#var cmd_args = {}

func _ready():
	#for cmdline in OS.get_cmdline_args():
			#if cmdline.contains("="):
				#var key_value = cmdline.split("=")
				#cmd_args[key_value[0].trim_prefix("--")] = key_value[1]
			#else:
				# Options without an argument will be present in the dictionary,
				# with the value set to an empty string.
				#cmd_args[cmdline.trim_prefix("--")] = ""
	if "brc_dedicate" in Global.cmd_args:
		start_server()
	peer.peer_connected.connect(peer_connected)
	peer.peer_disconnected.connect(peer_disconnected)

var server_counter = 0

func server_namer(new_line=true):
	if new_line:
		server_counter += 1
	return "{0}[b][color=wheat]Server ({1}):[/color][/b] ".format(["\n"if new_line else "",server_counter])

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
			print("\n\n----------------------------------\n\n")
			print_rich(server_namer(),data)
			
			if data.msg == brc_mpol.broadcast_msg.lobby:
				print_rich(server_namer(),"Lobby fire")
				join_lobby(data)
			
			if int(data.msg) in [brc_mpol.broadcast_msg.offer,brc_mpol.broadcast_msg.answer,brc_mpol.broadcast_msg.candidate]: #[6.0,7.0,5.0]
				print_rich(server_namer(),"Soruce ID is ",data.org_peer)#," Messge data ", data.data)
				data["server_counter"] = (server_namer(false)+" An offer, answer, or candidate.")
				msg_peer_data(data.peer,data)


func start_server():
	$"../ServerButton".disabled = true
	$"../test2".disabled = false
	peer.create_server(8915)
	print_rich(server_namer(),"Start server")

func join_lobby(user):
	#var result = ""
	if user.lobby_value == "":
		user.lobby_value = gen_rand_str()
		lobbies[user.lobby_value] = brc_testing_lobby.new(user.id)
		print_rich(server_namer(),user.lobby_value)
	@warning_ignore("unused_variable")
	var player = lobbies[user.lobby_value].add_player(user.id,user.name)
	var svr_name = server_namer(false)
	for p in lobbies[user.lobby_value].players:
		
		svr_name = server_namer()
		var _data = {
			"msg": brc_mpol.broadcast_msg.userConnected,
			"count_when_fired":user.count_when_fired,
			"server_counter":(server_namer(false)+" Connected user"),
			"id": user.id,
			"name": user.name
		}
		print_rich(svr_name,"{0} player getting _data: {1}".format([p,_data]))
		if not p == user.id:
			print_rich(server_namer(false),"Yep, its doing it.")
			msg_peer_data(p,_data)
		else:
			print_rich(server_namer(false),"Nope, its not doing it.")
		
		
		svr_name = server_namer()
		var data2 = {
			"msg": brc_mpol.broadcast_msg.userConnected,
			"count_when_fired":user.count_when_fired,
			"server_counter":(server_namer(false)+" Connected user"),
			"id": lobbies[user.lobby_value].players[p].id,
			"name": lobbies[user.lobby_value].players[p].name
		}
		print_rich(svr_name,"{0} player getting data2: {1}".format([user.id,data2]))
		if not p == user.id:
			print_rich(server_namer(false),"Yep, its doing it.")
			msg_peer_data(user.id,data2)
		else:
			print_rich(server_namer(false),"Nope, its not doing it.")
		
		svr_name = server_namer()
		var lobby_info = {
			"msg":brc_mpol.broadcast_msg.lobby,
			"count_when_fired":user.count_when_fired,
			"server_counter":(server_namer(false)+" Lobby data"),
			"player_list":JSON.stringify(lobbies[user.lobby_value].players),
			"host":lobbies[user.lobby_value].host_id,
			"lobby_value": user.lobby_value
		}
		print_rich(svr_name,"{0} player getting lobby_info: {1}".format([p,lobby_info]))
		msg_peer_data(p, lobby_info)
	
	svr_name = server_namer()
	var data = {
		"msg": brc_mpol.broadcast_msg.userConnected,
		"count_when_fired":user.count_when_fired,
		"server_counter":(server_namer(false)+" Connected user"),
		"id":user.id,
		"player":lobbies[user.lobby_value].players[user.id]
	}
	print_rich(svr_name,"{0} player getting data: {1}".format([data.id,data]))
	print_rich(server_namer(false),"Nope, its not doing it.")
	#msg_peer_data(data.id,data)
	
	svr_name = server_namer()
	var lobby_brdcst = {
		"msg": brc_mpol.broadcast_msg.lobby_connection,
		"count_when_fired":user.count_when_fired,
		"server_counter":(server_namer(false)+" Lobby data"),
		"lobby_value":user.lobby_value,
		"lobby_preview":lobbies[user.lobby_value].players,
		"lobby_size":"{0} players".format([lobbies[user.lobby_value].players.size()])
	}
	print_rich(svr_name,"Every player getting lobby_info: {0}".format([lobby_brdcst]))
	peer.put_packet(JSON.stringify(lobby_brdcst).to_utf8_buffer())
	brc_mpol.lobbies = lobbies.duplicate(true)

func msg_peer_data(user_id,msg):
	peer.get_peer(user_id).put_packet(JSON.stringify(msg).to_utf8_buffer())

func gen_rand_str() -> String:
	var result = ""
	for i in range(32):
		var rand_index = randi() % chara_list.length()
		result += chara_list[rand_index]
	return result

func peer_connected(id):
	print_rich(server_namer(),"Peer Connected: ", id)
	users[id] = {
		"id": id,
		"server_counter":(server_namer(false)+" Id"),
		"msg": brc_mpol.broadcast_msg.id
	}
	msg_peer_data(id,users[id])
	pass

func peer_disconnected(id):
	print_rich(server_namer(),"Peer Disconnected: ", id)
	pass

func _on_server_button_button_down():
	start_server()


func _on_test_button_down():
	print_rich(server_namer(),"Server Ping.")
	var msg = {
		"msg":brc_mpol.broadcast_msg.checkIn,
		"server_counter":(server_namer(false)+" server ping"),
		"data": "Test"
	}
	peer.put_packet(JSON.stringify(msg).to_utf8_buffer())
	pass # Replace with function body.


func _on_count_refresh():
	server_counter = 0
