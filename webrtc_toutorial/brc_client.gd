extends Node

## Handles what type of messge is being sent through the packets.
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

func _ready():
	debug_colour = ["red","yellow","blue","green","purple"].pick_random()
	multiplayer.connected_to_server.connect(RTCSeverConnected)
	multiplayer.peer_connected.connect(RTCPeerConnected)
	multiplayer.peer_disconnected.connect(RTCPeerDisconnected)

var debug_colour = ""

func client_namer() -> String:
	return "[color={1}]Client {0}:[/color]".format([peer_name,debug_colour])

func RTCSeverConnected():
	print_rich(client_namer()," RTC Connected to server")
	pass
@warning_ignore("shadowed_variable")
func RTCPeerConnected(id):
	print_rich(client_namer()," RTC peer joined: ",id)
	pass
@warning_ignore("shadowed_variable")
func RTCPeerDisconnected(id):
	print_rich(client_namer()," RTC peer left: ",id)
	pass

var peer = WebSocketMultiplayerPeer.new()
var peer_name = ""
var id = 0
var peerRTC : WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
var host_id : int
var lobby_value = ""
@onready var player_name = $player_name

func _process(_delta):
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var datstr = packet.get_string_from_utf8()
			var data = JSON.parse_string(datstr)
			print_rich("----------------------------------")
			print_rich(client_namer()," Data resived")
			for i in data.keys():
				print_rich(client_namer()," {0} = {1}".format([i,data[i]]))
			if data.msg == broadcast_msg.id:
				id = data.id
				connected(id)
				print_rich(client_namer()," This is my ID, DON'T LOSE IT: ",id)
			
			if data.msg == broadcast_msg.userConnected:
				print_rich(client_namer()," userConnected fire ",id," ",data.id)
				#Global.mp_player_list[data.id] = data.player
				create_peer(data.id)
			
			if data.msg == broadcast_msg.lobby:
				print_rich(client_namer()," Lobby fire")
				Global.mp_player_list = JSON.parse_string(data.player_list)
				host_id = data.host
				lobby_value = data.lobby_value
			
			if data.msg == broadcast_msg.candidate:
				if peerRTC.has_peer(data.org_peer):
					print_rich(client_namer()," Get Candidate ",data.org_peer," my id is ",id)
					peerRTC.get_peer(data.org_peer).connection.add_ice_candidate(data.mid,data.index,data.SDP)
			
			if data.msg == broadcast_msg.offer:
				print_rich(client_namer()," Offer fire")
				if peerRTC.has_peer(data.org_peer):
					peerRTC.get_peer(data.org_peer).connection.set_remote_description("offer", data.data)
			
			if data.msg == broadcast_msg.answer:
				print_rich(client_namer()," Answer fire")
				if peerRTC.has_peer(data.org_peer):
					peerRTC.get_peer(data.org_peer).connection.set_remote_description("answer", data.data)

@warning_ignore("shadowed_variable")
func connected(id):
	peerRTC.create_mesh(id)
	multiplayer.multiplayer_peer = peerRTC

# Web rtc connection
@warning_ignore("shadowed_variable")
func create_peer(id):
	if id != self.id:
		@warning_ignore("shadowed_variable")
		var peer : WebRTCPeerConnection = WebRTCPeerConnection.new()
		peer.initialize({
			"ice_server":[{"Urls":["stun:stun.l.google.com:19302"]}]
		})
		print_rich(client_namer()," Binding ID",id,"\nMy ID Is ",self.id)
		
		peer.session_description_created.connect(self.msg_offer_sent.bind(id))
		peer.ice_candidate_created.connect(self.msg_ice_sent.bind(id))
		peerRTC.add_peer(peer,id)
		
		if !host_id == self.id: # Was id < peerRTC.get_unique_id():
			print_rich(client_namer()," The host id {0} doesn't match the user ID: {1}".format([host_id,self.id]))
			peer.create_offer()
		else:
			print_rich(client_namer()," The host id {0} matches the user ID: {1}".format([host_id,self.id]))

@warning_ignore("shadowed_variable")
func msg_offer_sent(type, data, id):
	if !peerRTC.has_peer(id):
		return
	peerRTC.get_peer(id).connection.set_local_description(type,data)
	
	if type == "offer":
		send_offer(id,data)
	elif type == "answer":
		send_answer(id,data)

@warning_ignore("shadowed_variable")
func send_offer(id,data):
	var msg = {
		"peer":id,
		"org_peer":self.id,
		"msg": broadcast_msg.offer,
		"data": data,
		"lobby_value": lobby_value
	}
	peer.put_packet(JSON.stringify(msg).to_utf8_buffer())

@warning_ignore("shadowed_variable")
func send_answer(id,data):
	var msg = {
		"peer":id,
		"org_peer":self.id,
		"msg": broadcast_msg.answer,
		"data": data,
		"lobby_value": lobby_value
	}
	peer.put_packet(JSON.stringify(msg).to_utf8_buffer())

@warning_ignore("shadowed_variable")
func msg_ice_sent(mid_name,index_name,SDP_name,id):
	var msg = {
		"peer":id,
		"org_peer":self.id,
		"msg": broadcast_msg.candidate,
		"mid": mid_name,
		"index":index_name,
		"SDP":SDP_name,
		"lobby_value": lobby_value
	}
	peer.put_packet(JSON.stringify(msg).to_utf8_buffer())
	pass



@warning_ignore("unused_parameter")
func connect_to_server(ip):
	peer.create_client("ws://127.0.0.1:8915")
	print_rich(client_namer()," Start client")

func _on_client_button_button_down():
	connect_to_server("")


func _on_test_button_down():
	#var msg = {
		#"msg":broadcast_msg.join,
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
	var msg = {
		"id":id,
		"name":peer_name,
		"msg":broadcast_msg.lobby,
		"lobby_value":$lobby_name_line.text
	}
	peer.put_packet(JSON.stringify(msg).to_utf8_buffer())
	pass # Replace with function body.


@onready var v_slider = $"../VSlider"

@rpc("any_peer")
func _on_v_slider_value_changed(value,mp_player_source=true):
	if mp_player_source and mpol.test_slider_value != value:
		mpol.test_slider_value = value
		_on_v_slider_value_changed.rpc(value,false)
	elif v_slider.value != value:
		#print_rich("Client: Resived ping ")
		mpol.test_slider_value = value
		v_slider.value = value
	pass # Replace with function body.


func _on_player_name_text_changed(new_text):
	peer_name = new_text
