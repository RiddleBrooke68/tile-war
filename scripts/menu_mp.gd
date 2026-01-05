extends menu_class

# LOCAL MULTIPLAYER SHIT
# IDK
@export var game_mp : PackedScene
@export var server_join : PackedScene
@export var address = "192.168.17.140"
var address_broadcast = "192.168.17.255"
@export var port = 65535
var is_hosting = false
var is_joining = false
var server_name = ""
var client_name = ""
var peer : ENetMultiplayerPeer
var peerUDP : PacketPeerUDP

@onready var host_button = $host_menu/host_game
@onready var join_button = $join_menu/join_game
@onready var server_label = $host_menu/server_name
@onready var client_label = $host_menu/client_settings/client_name
@onready var server_ip_label = $host_menu/client_settings/server_input/server_ip
@onready var server_port_label = $host_menu/client_settings/server_input/server_port
@onready var host_menu = $host_menu
@onready var join_menu = $join_menu
@onready var server_browser = $join_menu/avalable_servers/BoxContainer/ScrollContainer/server_browser

func _ready():
	super()
	# In the main menu, the ready function makes sure this is set to false, 
	# so after we run the class ready function, we make this true.
	Global.mp_enabled = true
	# Broadcasting
	peerUDP = PacketPeerUDP.new()
	peerUDP.bind(4444)
	
	multiplayer.peer_connected.connect(player_connected)
	multiplayer.peer_disconnected.connect(player_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
	server_name = str(OS.get_environment("COMPUTERNAME"))
	server_label.text = server_name
	client_label.text = client_name
	
	set_id(IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),IP.TYPE_IPV4))
	port = randi_range(1,65535)
	server_ip_label.text = address
	server_port_label.text = str(port)

func set_id(ip):
	address = ip
	var broadcast_int = address.split(".")
	address_broadcast = "{0}.{1}.{2}.{3}".format([broadcast_int[0],broadcast_int[1],broadcast_int[2],"255"])

func select_server(select_name:String,select_ip:String,select_port:int):
	server_label.text = select_name
	_on_server_name_text_changed(select_name)
	server_ip_label.text = select_ip
	_on_server_ip_text_changed(select_ip)
	server_port_label.text = str(select_port)
	_on_server_port_text_changed(str(select_port))

func _on_server_name_text_changed(new_text):
	server_name = new_text

func _on_client_name_text_changed(new_text):
	host_button.disabled = new_text == ""
	join_button.disabled = new_text == ""
	client_name = new_text

## Sets the player IP.
func _on_server_ip_text_changed(new_text):
	set_id(new_text)
	print()
	#if new_text in IP.get_local_addresses():
		#address = new_text
	#else:
		#server_ip_label.text = address

## Sets the player Port.
func _on_server_port_text_changed(new_text:String):
	if new_text.to_int() in range(1,65535):
		port = new_text.to_int()
	else:
		server_port_label.text = str(port)


var resiving_mesge = false
var resive_digit = 0
var svr_mp_game_id = ""
var svr_mp_name = ""
var svr_mp_address = ""
var svr_mp_port = ""
func _process(_delta):
	if not is_hosting and not is_joining:
		var _s = peerUDP.get_available_packet_count()
		if peerUDP.get_available_packet_count() > 0:
			var array_bytes = peerUDP.get_packet()
			var game_id = array_bytes.get_string_from_ascii()
			print("Received message: ", game_id)
			if game_id.to_int() == Global.app_id and resive_digit == 0:
				resiving_mesge = true
				svr_mp_game_id = game_id
			var list_of_servers = [""]
			for i in get_tree().get_nodes_in_group("server_connection"):
				list_of_servers.append(i.server_name)
			if not game_id in list_of_servers and resive_digit == 1:
				svr_mp_name = game_id
			if game_id.is_valid_ip_address() and resive_digit == 2:
				svr_mp_address = game_id
			if game_id.to_int() in range(1,65535) and resive_digit == 3:
				svr_mp_port = game_id
			if svr_mp_game_id.to_int() == Global.app_id and not svr_mp_name in list_of_servers and svr_mp_address.is_valid_ip_address() and svr_mp_port.to_int() in range(1,65535):
				var server_panel = server_join.instantiate()
				server_panel.server_name = svr_mp_name
				server_panel.server_address = svr_mp_address
				server_panel.server_port = svr_mp_port.to_int()
				server_browser.add_child(server_panel)
				server_panel.selected_server.connect(select_server)
			resive_digit += 1
		elif resiving_mesge:
			resiving_mesge = false
			resive_digit = 0
			svr_mp_game_id = ""
			svr_mp_name = ""
			svr_mp_address = ""
			svr_mp_port = ""
			#if array_bytes.size() == 4:
				#game_id = array_bytes[0].get_string_from_ascii()
				#var svr_name = array_bytes[1].get_string_from_ascii()
				#var svr_adr = array_bytes[2].get_string_from_ascii()
				#var svr_prt = array_bytes[3].get_string_from_ascii()
				#if game_id.to_int() == Global.app_id:
					#var server_panel = server_join.instantiate()
					#server_panel.server_name = svr_name
					#server_panel.server_address = svr_adr
					#server_panel.server_port = svr_prt
					#server_browser.add_child(server_panel)
					#server_panel.selected_server.connect(select_server)

# MP BUTTONS
## Called when a player connects to a server, regadless of client or  server
func player_connected(id):
	print("player connected: " + str(id))

## Called when a player disconnects to a server, regadless of client or  server
func player_disconnected(id):
	print("player disconnected: " + str(id))

## Called when the client connects to the server.
func connected_to_server():
	print("Connected to server")
	host_menu.hide()
	join_menu.hide()
	for i in get_tree().get_nodes_in_group("menu_settings_ui"):
		i.show()
	send_player_data.rpc_id(1,client_label.text,multiplayer.get_unique_id())

## Called when the client fails connects to the server.
func connection_failed():
	print("Failed to connect")
	is_joining = false
	


@rpc("any_peer")
func send_player_data(_name,id):
	if not Global.mp_player_list.has(id):
		Global.mp_player_list[id] = {
			"name": _name,
			"id": id,
			"current_claim": 0
		}
	if multiplayer.is_server():
		for i in Global.mp_player_list:
			send_player_data.rpc(Global.mp_player_list[i].name, i)


@rpc("any_peer","call_local")
func start_game():
	var scene = game_mp.instantiate()
	get_tree().root.add_child(scene)
	self.hide()


func _on_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port,4)
	if error  != OK:
		print("Can not host: ",error)
		if error == ERR_ALREADY_IN_USE:
			peer.close()
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Awaitng for players, {0}, {1}".format([address,port]))
	send_player_data(client_label.text,multiplayer.get_unique_id())
	
	host_menu.hide()
	join_menu.hide()
	for i in get_tree().get_nodes_in_group("menu_settings_ui"):
		i.show()
	
	peerUDP = PacketPeerUDP.new()
	peerUDP.bind(4433)
	
	is_hosting = true
	peerUDP.set_broadcast_enabled(true)
	peerUDP.set_dest_address(address_broadcast,4444)
	peerUDP.put_packet(str(Global.app_id).to_utf8_buffer())
	peerUDP.put_packet(server_name.to_utf8_buffer())
	peerUDP.put_packet(address.to_utf8_buffer())
	peerUDP.put_packet(str(port).to_utf8_buffer())
	timer.start()



func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	
	is_joining = true


func _on_start_button_down():
	if is_hosting:
		start_game.rpc()

@onready var timer = $Timer

func update_broadcast_data():
	peerUDP.set_dest_address(address_broadcast,4444)
	peerUDP.put_packet(str(Global.app_id).to_utf8_buffer())
	peerUDP.put_packet(server_name.to_utf8_buffer())
	peerUDP.put_packet(address.to_utf8_buffer())
	peerUDP.put_packet(str(port).to_utf8_buffer())
