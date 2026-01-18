extends Node
class_name menu_mpol_svr_class

func _ready():
	if "mpol_svr_dedicate" in Global.cmd_args:
		start_server()
	peerWEB.peer_connected.connect(peer_connected)
	peerWEB.peer_disconnected.connect(peer_disconnected)

var server_counter = 0

func server_namer(new_line=true):
	if new_line:
		server_counter += 1
	return "{0}[b][color=wheat]Server ({1}):[/color][/b] ".format(["\n"if new_line else "",server_counter])

var peerWEB = WebSocketMultiplayerPeer.new()

const chara_list = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

func _process(_delta):
	peerWEB.poll()
	if peerWEB.get_available_packet_count() > 0:
		var packet = peerWEB.get_packet()
		if packet != null:
			var datstr = packet.get_string_from_utf8()
			var data = JSON.parse_string(datstr)
			print("\n\n----------------------------------\n\n")
			print_rich(server_namer(),data)
			
			if data.msg == Global.msg.lobby:
				print_rich(server_namer(),"Lobby fire")
				join_lobby(data)
			
			if int(data.msg) in [Global.msg.offer,Global.msg.answer,Global.msg.candidate]: #[6.0,7.0,5.0]
				print_rich(server_namer(),"Soruce ID is ",data.org_peer)#," Messge data ", data.data)
				data["server_counter"] = server_namer(false)
				msg_peer_data(data.peerWEB,data)


func start_server():
	$"../ServerButton".disabled = true
	$"../test2".disabled = false
	peerWEB.create_server(8915)
	print_rich(server_namer(),"Start server")

func join_lobby(user):
	#var result = ""
	if user.lobby_address == "":
		user.lobby_address = gen_rand_str()
		Global.mpol_svr_lobbies[user.lobby_name] = brc_testing_lobby.new(user.id)
		print_rich(server_namer(),user.lobby_name)
	@warning_ignore("unused_variable")
	var player = Global.mpol_svr_lobbies[user.lobby_name].add_player(user.id,user.name)
	var svr_name = server_namer(false)
	for p in Global.mpol_svr_lobbies[user.lobby_name].players:
		
		svr_name = server_namer()
		var _data = {
			"msg": Global.msg.userConnected,
			"count_when_fired":user.count_when_fired,
			"server_counter":server_namer(false),
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
			"msg": Global.msg.userConnected,
			"count_when_fired":user.count_when_fired,
			"server_counter":server_namer(false),
			"id": Global.mpol_svr_lobbies[user.lobby_name].players[p].id,
			"name": Global.mpol_svr_lobbies[user.lobby_name].players[p].name
		}
		print_rich(svr_name,"{0} player getting data2: {1}".format([user.id,data2]))
		if not p == user.id:
			print_rich(server_namer(false),"Yep, its doing it.")
			msg_peer_data(user.id,data2)
		else:
			print_rich(server_namer(false),"Nope, its not doing it.")
		
		svr_name = server_namer()
		var lobby_info = {
			"msg":Global.msg.lobby,
			"count_when_fired":user.count_when_fired,
			"server_counter":server_namer(false),
			"player_list":JSON.stringify(Global.mpol_svr_lobbies[user.lobby_name].players),
			"host":Global.mpol_svr_lobbies[user.lobby_name].host_id,
			"lobby_name":user.lobby_name,
			"lobby_address": user.lobby_address
		}
		print_rich(svr_name,"{0} player getting lobby_info: {1}".format([p,lobby_info]))
		msg_peer_data(p, lobby_info)
	
	svr_name = server_namer()
	var data = {
		"msg": Global.msg.userConnected,
		"count_when_fired":user.count_when_fired,
		"server_counter":server_namer(false),
		"id":user.id,
		"player":Global.mpol_svr_lobbies[user.lobby_name].players[user.id]
	}
	print_rich(svr_name,"{0} player getting data: {1}".format([data.id,data]))
	print_rich(server_namer(false),"Nope, its not doing it.")
	#msg_peer_data(data.id,data)
	
	svr_name = server_namer()
	var lobby_brdcst = {
		"msg": Global.msg.lobby_connection,
		"count_when_fired":user.count_when_fired,
		"server_counter":server_namer(false),
		"lobby_name":user.lobby_name,
		"lobby_address":user.lobby_address,
		"lobby_preview":Global.mpol_svr_lobbies[user.lobby_name].players,
		"lobby_size":"{0} players".format([Global.mpol_svr_lobbies[user.lobby_name].players.size()])
	}
	print_rich(svr_name,"Every player getting lobby_info: {0}".format([lobby_brdcst]))
	peerWEB.put_packet(JSON.stringify(lobby_brdcst).to_utf8_buffer())
	#Global.Global.mpol_svr_lobbies = Global.mpol_svr_lobbies.duplicate(true)

func msg_peer_data(user_id,msg):
	peerWEB.get_peer(user_id).put_packet(JSON.stringify(msg).to_utf8_buffer())

func gen_rand_str() -> String:
	var result = ""
	for i in range(32):
		var rand_index = randi() % chara_list.length()
		result += chara_list[rand_index]
	return result

func peer_connected(id):
	print_rich(server_namer(),"Peer Connected: ", id)
	Global.mpol_svr_users[id] = {
		"id": id,
		"server_counter":server_namer(false),
		"msg": Global.msg.id
	}
	msg_peer_data(id,Global.mpol_svr_users[id])
	pass

func peer_disconnected(id):
	print_rich(server_namer(),"Peer Disconnected: ", id)
	pass

func _on_server_button_button_down():
	start_server()


func _on_test_button_down():
	print_rich(server_namer(),"Server Ping.")
	var msg = {
		"msg":Global.msg.checkIn,
		"server_counter":server_namer(false),
		"data": "Test"
	}
	peerWEB.put_packet(JSON.stringify(msg).to_utf8_buffer())
	pass # Replace with function body.


func _on_count_refresh():
	server_counter = 0
