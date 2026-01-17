extends Node

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
	if "mp_name" in Global.cmd_args.keys():
		peer_name = Global.cmd_args["mp_name"] 
		player_name.text = peer_name
	
	debug_colour = ["red","yellow","light_blue","green","purple","deep_pink","aqua","dark_orange","turquoise","violet"].pick_random()
	multiplayer.connected_to_server.connect(RTCSeverConnected)
	multiplayer.peer_connected.connect(RTCPeerConnected)
	multiplayer.peer_disconnected.connect(RTCPeerDisconnected)
	peerRTC.peer_connected.connect(RTCPeerConnected)
	peerRTC.peer_disconnected.connect(RTCPeerDisconnected)

var debug_colour = ""
var call_number = 0

func client_namer(new_line=true) -> String:
	if new_line:
		call_number += 1
	return "{3}[color={1}]Client {0} ({2}):[/color]".format([peer_name,debug_colour,call_number,"\n"if new_line else ""])

func RTCSeverConnected():
	print_rich(client_namer()," RTC Connected to server")
	mpol.connected = true


@warning_ignore("shadowed_variable")
func RTCPeerConnected(id):
	print_rich(client_namer()," RTC peer joined: {0},".format([id]))
	mpol.connected = true


@warning_ignore("shadowed_variable")
func RTCPeerDisconnected(id):
	print_rich(client_namer()," RTC peer left: ",id)


var peer = WebSocketMultiplayerPeer.new()
var peer_name = ""
var id = 0
var peerRTC : WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
var host_id : int
@onready var lobby_name_line = $lobby_name_line
var lobby_value = "":
	set(i):
		lobby_name_line.text = i
		lobby_value = i
var server_join : PackedScene = preload("res://objects/ui/main_menu/server_connection_button.tscn") as PackedScene
@onready var player_name = $player_name
@onready var server_browser = $"../join_menu/avalable_servers/BoxContainer/ScrollContainer/server_browser"

func _on_player_name_text_changed(new_text):
	peer_name = new_text


func _process(_delta):
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var datstr = packet.get_string_from_utf8()
			var data = JSON.parse_string(datstr)
			print_rich("\n\n----------------------------------\n")
			print_rich(client_namer()," Data resived")
			for i in data.keys():
				if i != "data":
					print_rich(client_namer()," {0} = {1}".format([i,data[i]]))
				else:
					print_rich(client_namer()," {0} = {1}".format([i,data[i]]))
			if data.msg == mpol.broadcast_msg.id:
				id = data.id
				connected(id)
				print_rich(client_namer()," This is my ID, DON'T LOSE IT: ",id)
			
			if data.msg == mpol.broadcast_msg.userConnected:
				print_rich(client_namer()," userConnected fire: {0} and {1}\n				Do they Match: {2}".format([id,data.id,id==data.id]))
				create_peer(data.id)
				#msg_offer_sent("answer",data,data.id)
			
			if data.msg == mpol.broadcast_msg.lobby:
				print_rich(client_namer()," Lobby fire")
				#Global.mp_player_list = JSON.parse_string(data.player_list)
				mpol.player_list = JSON.parse_string(data.player_list)
				host_id = data.host
				lobby_value = data.lobby_value
			
			if data.msg == mpol.broadcast_msg.lobby_connection:
				var list_of_servers_names = {}
				for i in get_tree().get_nodes_in_group("server_connection"):
					list_of_servers_names[i.server_name] = i
				if not data.lobby_value in list_of_servers_names.keys():
					var server_panel = server_join.instantiate()
					server_panel.server_name = data.lobby_value
					#server_panel.server_port = svr_mp_port.to_int()
					server_browser.add_child(server_panel)
					server_panel.server_lobby_size = data.lobby_size
					server_panel.selected_server.connect(select_server)
				else:
					list_of_servers_names[data.lobby_value].server_lobby_size = data.lobby_size
			
			if data.msg == mpol.broadcast_msg.candidate:
				if peerRTC.has_peer(data.org_peer):
					print_rich(client_namer()," Get Candidate ",data.org_peer," my id is ",id)
					peerRTC.get_peer(data.org_peer).connection.add_ice_candidate(data.mid,data.index,data.SDP)
			
			if data.msg == mpol.broadcast_msg.offer:
				print_rich(client_namer()," Offer fire")
				if peerRTC.has_peer(data.org_peer):
					peerRTC.get_peer(data.org_peer).connection.set_remote_description("offer", data.data)
			
			if data.msg == mpol.broadcast_msg.answer:
				print_rich(client_namer()," Answer fire")
				if peerRTC.has_peer(data.org_peer):
					peerRTC.get_peer(data.org_peer).connection.set_remote_description("answer", data.data)

## It doesn't fire when peerRTC connects?
@warning_ignore("shadowed_variable")
func connected(id):
	print_rich(client_namer()," Connected function fired")
	peerRTC.create_mesh(id)
	multiplayer.set_multiplayer_peer(peerRTC)


func select_server(select_name:String,_select_ip:String,_select_port:int):
	lobby_name_line.text = select_name

# Web rtc connection
@warning_ignore("shadowed_variable")
func create_peer(id):
	if id != self.id:
		@warning_ignore("shadowed_variable")
		var peer : WebRTCPeerConnection = WebRTCPeerConnection.new()
		var err = peer.initialize({
			"ice_server":[{"Urls":["stun:stun.l.google.com:19302"]}]
		})
		print_rich(client_namer()," Binding ID",id,"\n				My ID Is ",self.id)
		
		if err != OK:
			print_rich("[color=red][b]BRC_NET_ERROR.001:[/b] Connection error. The game will break after this,\n[center]GAME CRASH[/center]\n{0}[/color]".format([err]))
			OS.alert("Error: Connection error. The game will break after this,\nGAME CRASH", "BRC_NET_ERROR.001")
			OS.crash("ERROR")
		peer.session_description_created.connect(self.msg_offer_sent.bind(id))
		peer.ice_candidate_created.connect(self.msg_ice_sent.bind(id))
		err = peerRTC.add_peer(peer,id)
		
		if err != OK:
			print_rich("[color=red][b]BRC_NET_ERROR.001:[/b] Connection error. The game will break after this,\n[center]GAME CRASH[/center]\n{0}[/color]".format([err]))
			OS.alert("Error: Connection error. The game will break after this,\nGAME CRASH", "BRC_NET_ERROR.001")
			OS.crash("ERROR")
		if !host_id == self.id: # Was id < peerRTC.get_unique_id():
			print_rich(client_namer()," The host id {0} doesn't match the user ID: {1}".format([host_id,self.id]))
			peer.create_offer()
		else:
			print_rich(client_namer()," The host id {0} matches the user ID: {1}".format([host_id,self.id]))
			_on_lobby_join_button_button_down()

@warning_ignore("shadowed_variable")
func msg_offer_sent(type, data, id):
	if !peerRTC.has_peer(id):
		return
	peerRTC.get_peer(id).connection.set_local_description(type,data)
	
	if type == "offer":
		print_rich(client_namer()," Sending Offer")
		send_offer(id,data)
	elif type == "answer":
		print_rich(client_namer()," Sending Answer")
		send_answer(id,data)

@warning_ignore("shadowed_variable")
func send_offer(id,data):
	var msg = {
		"count_when_fired":client_namer(false),
		"peer":id,
		"org_peer":self.id,
		"msg": mpol.broadcast_msg.offer,
		"data": data,
		"lobby_value": lobby_value
	}
	peer.put_packet(JSON.stringify(msg).to_utf8_buffer())

@warning_ignore("shadowed_variable")
func send_answer(id,data):
	var msg = {
		"count_when_fired":client_namer(false),
		"peer":id,
		"org_peer":self.id,
		"msg": mpol.broadcast_msg.answer,
		"data": data,
		"lobby_value": lobby_value
	}
	peer.put_packet(JSON.stringify(msg).to_utf8_buffer())

@warning_ignore("shadowed_variable")
func msg_ice_sent(mid_name,index_name,SDP_name,id):
	var msg = {
		"count_when_fired":client_namer(false),
		"peer":id,
		"org_peer":self.id,
		"msg": mpol.broadcast_msg.candidate,
		"mid": mid_name,
		"index":index_name,
		"SDP":SDP_name,
		"lobby_value": lobby_value
	}
	peer.put_packet(JSON.stringify(msg).to_utf8_buffer())
	pass



@warning_ignore("unused_parameter")
func connect_to_server(ip):
	var err = peer.create_client("ws://192.168.17.140:8915")
	print_rich(client_namer()," Start client: ",err)

func _on_client_button_button_down():
	connect_to_server("")


func _on_test_button_down():
	#var msg = {
		#"msg":mpol.broadcast_msg.join,
		#"data": "Test"
	#}
	#var msg_byte = JSON.stringify(msg).to_utf8_buffer()
	#peer.put_packet(msg_byte)
	ping.rpc()
	pass # Replace with function body.

@rpc("any_peer")
func ping():
	print_rich(client_namer()," PINGED ",multiplayer.get_remote_sender_id())

func _on_lobby_join_button_button_down():
	print_rich(client_namer()," Sending a lobby join thingy.")
	var msg = {
		"count_when_fired":client_namer(false),
		"id":id,
		"name":peer_name,
		"msg":mpol.broadcast_msg.lobby,
		"lobby_value":$lobby_name_line.text
	}
	peer.put_packet(JSON.stringify(msg).to_utf8_buffer())
	pass # Replace with function body.


@onready var v_slider = $"../VSlider"

@rpc("any_peer")
func _on_v_slider_value_changed(value,mp_player_source=true):
	if mp_player_source and mpol.test_slider_value != value and mpol.connected:
		mpol.test_slider_value = value
		_on_v_slider_value_changed.rpc(value,false)
	elif v_slider.value != value:
		#print_rich("Client: Resived ping ")
		mpol.test_slider_value = value
		v_slider.value = value
	pass # Replace with function body.


func _on_colour_refresh():
	debug_colour = ["red","yellow","light_blue","green","purple","deep_pink","aqua","dark_orange","turquoise","violet"].pick_random()
	print_rich(client_namer()," NEW COLOUR")


func _on_count_refresh():
	call_number = 0
