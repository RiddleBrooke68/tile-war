
## This is both like menu_mp and brc_client
extends menu_class
class_name menu_mpol_clnt_class


@export var game_mp : PackedScene
@export var server_join : PackedScene
@export var player_plate : PackedScene
## This is the address of a server player can use theirs or.
@export var server_address = "192.168.17.140"


var lobby_name = ""
var lobby_address = ""

var client_name = ""
## Its like peer from menu_mp, but instead, it uses WebRTC
var peerRTC : WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
## Its like peerUDP from menu_mp, but intead it uses WebSocket
var peerWEB = WebSocketMultiplayerPeer.new()
var peer_name = ""
var id = 0
var host_id : int

@onready var host_game : Button = %host_game
@onready var join_game : Button = %join_game
@onready var server_ip_label : LineEdit = %server_ip
@onready var client_text : LineEdit = %client_name
@onready var lobby_text : LineEdit = %lobby_name
@onready var lobby_codeline : LineEdit = %lobby_code
@onready var join_server_button : Button = %join_server


func _ready(is_updating=false):
	super(is_updating)
	Global.mp_enabled = true
	
	if "mp_name" in Global.cmd_args.keys():
		client_name = Global.cmd_args["mp_name"] 
	# In the main menu, the ready function makes sure this is set to false, 
	# so after we run the class ready function, we make this true.
	
	if not is_updating:
		
		#Global.mp_player_list_changed.connect(set_lobby_player_list)
		debug_colour = ["red","yellow","light_blue","green","purple","deep_pink","aqua","dark_orange","turquoise","violet"].pick_random() #NEW
		multiplayer.connected_to_server.connect(RTCSeverConnected)
		multiplayer.peer_connected.connect(RTCPeerConnected)
		multiplayer.peer_disconnected.connect(RTCPeerDisconnected)
		peerRTC.peer_connected.connect(RTCPeerConnected)
		peerRTC.peer_disconnected.connect(RTCPeerDisconnected)
		
		set_id()
		server_ip_label.text = server_address

## Its here so I know which client is which when debuging.
var debug_colour = "" 
## Its here so I know when a call fired in the debug.
var call_number = 0 
## To make it easer to know which clients printed what. 
func client_namer(new_line=true) -> String: 
	if new_line: 
		call_number += 1 
	return "{3}[color={1}]Client {0} ({2}):[/color]".format([peer_name,debug_colour,call_number,"\n"if new_line else ""])
## When a peer connects to a lobby
func RTCSeverConnected():
	print_rich(client_namer()," RTC Connected to lobby")
	brc_mpol.connected = true 
## Like [method menu_mp_class.player_connected]
@warning_ignore("shadowed_variable")
func RTCPeerConnected(id):
	print_rich(client_namer()," RTC peer joined: {0},".format([id]))
	brc_mpol.connected = true 
## Like [method menu_mp_class.player_disconnected]
@warning_ignore("shadowed_variable")
func RTCPeerDisconnected(id):
	print_rich(client_namer()," RTC peer left: ",id)


func set_id(ip=""):
	var address_x = IP.get_local_interfaces()
	if ip == "":
		for interface in address_x:
			if interface.friendly in ["WiFi","Ethernet"]:
				server_address = interface.addresses.back()
	else:
		server_address = ip

func select_server(select_name:String,select_addres:String,_select_port:int):
	lobby_text.text = select_name
	_on_lobby_name_text_changed(select_name)
	lobby_codeline.text = select_addres
	_on_lobby_code_text_changed(select_addres)

func _on_client_name_text_changed(new_text):
	client_name = new_text

func _on_lobby_name_text_changed(new_text):
	lobby_name = new_text

func _on_lobby_code_text_changed(new_text):
	lobby_address = new_text


# BRDCST shit
func _process(_delta):
	peerWEB.poll()
	if peerWEB.get_available_packet_count() > 0:
		var packet = peerWEB.get_packet()
		if packet != null:
			var datstr = packet.get_string_from_utf8()
			var data = JSON.parse_string(datstr)
			print_rich("\n\n----------------------------------\n")
			print_rich(client_namer()," Data resived")
			#if not int(data.msg) in filter:
			for i in data.keys():
				if i != "data":
					print_rich(client_namer()," {0} = {1}".format([i,data[i]]))
				else:
					print_rich(client_namer()," {0} = {1}".format([i,data[i]]))

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
		
		if err != OK: #NEW
			print_rich("[color=red][b]BRC_NET_ERROR.001:[/b] Connection error. The game will break after this,\n[center]GAME CRASH[/center]\n{0}[/color]".format([err])) #NEW
			OS.alert("Error: Connection error. The game will break after this,\nGAME CRASH", "BRC_NET_ERROR.001") #NEW
			OS.crash("ERROR") #NEW
		peer.session_description_created.connect(self.msg_offer_sent.bind(id))
		peer.ice_candidate_created.connect(self.msg_ice_sent.bind(id))
		err = peerRTC.add_peer(peer,id)
		
		if err != OK:
			print_rich("[color=red][b]BRC_NET_ERROR.001:[/b] Connection error. The game will break after this,\n[center]GAME CRASH[/center]\n{0}[/color]".format([err]))
			OS.alert("Error: Connection error. The game will break after this,\nGAME CRASH", "BRC_NET_ERROR.001")
			OS.crash("ERROR")
		# Ok, so if the host has the same id as the player creating the peer, ie: the one who resived the user connected, then it wont create a offer to it.
		# So when a player joins a new lobby, the host will resive that they joined, but wont send them a 
		if id < peerRTC.get_unique_id(): # Was !host_id == self.id:
			print_rich(client_namer()," The host id {0} doesn't match the user ID: {1}".format([host_id,self.id]))
			peer.create_offer()
		else:
			print_rich(client_namer()," The host id {0} matches the user ID: {1}".format([host_id,self.id]))
			#_on_lobby_join_button_button_down()

## This sends out a offer
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
		"msg": brc_mpol.broadcast_msg.offer,
		"data": data,
		"lobby_address": lobby_address
	}
	peerWEB.put_packet(JSON.stringify(msg).to_utf8_buffer())

@warning_ignore("shadowed_variable")
func send_answer(id,data):
	var msg = {
		"count_when_fired":client_namer(false),
		"peer":id,
		"org_peer":self.id,
		"msg": brc_mpol.broadcast_msg.answer,
		"data": data,
		"lobby_address": lobby_address
	}
	peerWEB.put_packet(JSON.stringify(msg).to_utf8_buffer())

@warning_ignore("shadowed_variable")
func msg_ice_sent(mid_name,index_name,SDP_name,id):
	var msg = {
		"count_when_fired":client_namer(false),
		"peer":id,
		"org_peer":self.id,
		"msg": brc_mpol.broadcast_msg.candidate,
		"mid": mid_name,
		"index":index_name,
		"SDP":SDP_name,
		"lobby_address": lobby_address
	}
	peerWEB.put_packet(JSON.stringify(msg).to_utf8_buffer())
	pass



@warning_ignore("unused_parameter")
func connect_to_server(ip):
	var err = peerWEB.create_client("ws://{0}:8915".format([server_address]))
	print_rich(client_namer()," Start client: ",err)

func _on_client_button_button_down():
	join_server_button.disabled = true
	connect_to_server("")
