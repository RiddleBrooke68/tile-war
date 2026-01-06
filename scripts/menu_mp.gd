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

func _ready(is_updating=false):
	super()
	if not is_updating:
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
		multiplayer.server_disconnected.connect(server_disconnected)
		
		server_name = str(OS.get_environment("COMPUTERNAME"))
		server_label.text = server_name
		client_label.text = client_name
		
		set_id() # IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),IP.TYPE_IPV4)
		port = randi_range(1,65535)
		server_ip_label.text = address
		server_port_label.text = str(port)


@onready var green_picker = %green_picker
@onready var purple_picker = %purple_picker
@onready var yellow_picker = %yellow_picker
@onready var red_picker = %red_picker
@onready var claims_picker_list = [green_picker,purple_picker,yellow_picker,red_picker]

@rpc("any_peer")
func _on_green_picker_toggled(toggled_on,mp_player_source=true,mp_name="",mp_id=""):
	if mp_player_source:
		if toggled_on:
			print(client_name," asining player to claim green: " + str(multiplayer.get_unique_id()))
			Global.mp_player_list[multiplayer.get_unique_id()].current_claim = 1
			green_claim_type.item_selected.emit(2,false)
			green_claim_type.disabled = true
			green_name.text = Global.mp_player_list[multiplayer.get_unique_id()].name
		else:
			Global.mp_player_list[multiplayer.get_unique_id()].current_claim = 0
			green_claim_type.item_selected.emit(0,false)
			green_claim_type.disabled = false
			green_name.text = ""
		_on_green_picker_toggled.rpc(toggled_on,false,green_name.text,multiplayer.get_unique_id())
	else:
		if toggled_on:
			Global.mp_player_list[mp_id].current_claim = 1
			green_claim_type.item_selected.emit(2,false)
			green_claim_type.disabled = true
			green_name.text = mp_name
			green_picker.disabled = true
		else:
			Global.mp_player_list[mp_id].current_claim = 0
			green_claim_type.item_selected.emit(0,false)
			green_claim_type.disabled = false
			green_name.text = ""
			green_picker.disabled = false

@rpc("any_peer")
func _on_purple_picker_toggled(toggled_on,mp_player_source=true,mp_name="",mp_id=""):
	if mp_player_source:
		if toggled_on:
			print(client_name," asining player to claim purple: " + str(multiplayer.get_unique_id()))
			Global.mp_player_list[multiplayer.get_unique_id()].current_claim = 2
			purple_claim_type.item_selected.emit(2,false)
			purple_claim_type.disabled = true
			purple_name.text = Global.mp_player_list[multiplayer.get_unique_id()].name
		else:
			Global.mp_player_list[multiplayer.get_unique_id()].current_claim = 0
			purple_claim_type.item_selected.emit(0,false)
			purple_claim_type.disabled = false
			purple_name.text = ""
		_on_purple_picker_toggled.rpc(toggled_on,false,purple_name.text,multiplayer.get_unique_id())
	else:
		if toggled_on:
			Global.mp_player_list[mp_id].current_claim = 2
			purple_claim_type.item_selected.emit(2,false)
			purple_claim_type.disabled = true
			purple_name.text = mp_name
			purple_picker.disabled = true
		else:
			Global.mp_player_list[mp_id].current_claim = 0
			purple_claim_type.item_selected.emit(0,false)
			purple_claim_type.disabled = false
			purple_name.text = ""
			purple_picker.disabled = false

@rpc("any_peer")
func _on_yellow_picker_toggled(toggled_on,mp_player_source=true,mp_name="",mp_id=""):
	if mp_player_source:
		if toggled_on:
			print(client_name," asining player to claim yellow: " + str(multiplayer.get_unique_id()))
			Global.mp_player_list[multiplayer.get_unique_id()].current_claim = 3
			yellow_claim_type.item_selected.emit(2,false)
			yellow_claim_type.disabled = true
			yellow_name.text = Global.mp_player_list[multiplayer.get_unique_id()].name
		else:
			Global.mp_player_list[multiplayer.get_unique_id()].current_claim = 0
			yellow_claim_type.item_selected.emit(0,false)
			yellow_claim_type.disabled = false
			yellow_name.text = ""
		_on_yellow_picker_toggled.rpc(toggled_on,false,yellow_name.text,multiplayer.get_unique_id())
	else:
		if toggled_on:
			Global.mp_player_list[mp_id].current_claim = 3
			yellow_claim_type.item_selected.emit(2,false)
			yellow_claim_type.disabled = true
			yellow_name.text = mp_name
			yellow_picker.disabled = true
		else:
			Global.mp_player_list[mp_id].current_claim = 0
			yellow_claim_type.item_selected.emit(0,false)
			yellow_claim_type.disabled = false
			yellow_name.text = ""
			yellow_picker.disabled = false

@rpc("any_peer")
func _on_red_picker_toggled(toggled_on,mp_player_source=true,mp_name="",mp_id=""):
	if mp_player_source:
		if toggled_on:
			print(client_name," asining player to claim red: " + str(multiplayer.get_unique_id()))
			Global.mp_player_list[multiplayer.get_unique_id()].current_claim = 4
			red_claim_type.item_selected.emit(2,false)
			red_claim_type.disabled = true
			red_name.text = Global.mp_player_list[multiplayer.get_unique_id()].name
		else:
			Global.mp_player_list[multiplayer.get_unique_id()].current_claim = 0
			red_claim_type.item_selected.emit(0,false)
			red_claim_type.disabled = false
			red_name.text = ""
		_on_red_picker_toggled.rpc(toggled_on,false,red_name.text,multiplayer.get_unique_id())
	else:
		if toggled_on:
			Global.mp_player_list[mp_id].current_claim = 4
			red_claim_type.item_selected.emit(2,false)
			red_claim_type.disabled = true
			red_name.text = mp_name
			red_picker.disabled = true
		else:
			Global.mp_player_list[mp_id].current_claim = 0
			red_claim_type.item_selected.emit(0,false)
			red_claim_type.disabled = false
			red_name.text = ""
			red_picker.disabled = false


func set_id(ip=""):
	var address_x = IP.get_local_interfaces()
	if ip == "":
		for interface in address_x:
			if interface.friendly in ["WiFi","Ethernet"]:
				address = interface.addresses.back()
	else:
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

## When it starts reading a signal it will atempt to read it.
var resiving_mesge = false
## This counts what part of the signal that is being resive is.
var resive_digit = 0
## The resived Game Id, see [member Global.app_id] for what that number is.
var svr_mp_game_id = ""
## The resived name of the server that is being detected.
var svr_mp_name = ""
## The resived address of which the server derives from.
var svr_mp_address = ""
## The resived port of which the server derives from.
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

# MP BUTTONS
## Called when a player connects to a server, regadless of client or  server
func player_connected(id):
	Global.mp_host = is_hosting
	if not Global.mp_player_list.is_empty():
		print(client_name," player connected: " + str(id))
		send_player_data.rpc_id(id,client_label.text,Global.mp_player_id,Global.mp_player_list[Global.mp_player_id].current_claim)
		#if Global.mp_host:
			#update_global_data.rpc_id(id,
				#Global.map_type,
				#Global.wall_count,
				#Global.fuel_count,
				#Global.cap_list,
				#Global.claim_list,
				#Global.ai_level,
				#Global.music_type,
				#Global.lms_enabled,
				#Global.bran_enabled,
				#Global.mp_player_list)

## Called when a player disconnects to a server, regadless of client or server
func player_disconnected(id):
	print(client_name," player disconnected: " + str(id))
	remove_player_data(id)
	

## Called when the client connects to the server.
func connected_to_server():
	print(client_name," Connected to server")
	for i in get_tree().get_nodes_in_group("menu_mp"):
		i.hide()
	for i in get_tree().get_nodes_in_group("menu_settings_ui"):
		i.show()
	Global.mp_player_id = multiplayer.get_unique_id()
	send_player_data.rpc_id(1,client_label.text,Global.mp_player_id)

## Called when the client fails connects to the server.
func connection_failed():
	print(client_name," Failed to connect")
	is_joining = false

func server_disconnected():
	print_rich(client_name," [color=red][b]NET_ERROR.001:[/b] It seems that a was just disconnected from the server.[/color]")
	OS.alert("Error: It seems that you were just disconnected from the server, try to rejoin if you can.", "NET_ERROR.001")
	is_joining = false
	peer = ENetMultiplayerPeer.new()
	Global.mp_player_id = 0
	Global.mp_player_list.clear()
	for i in get_tree().get_nodes_in_group("menu_mp"):
		i.show()
	for i in get_tree().get_nodes_in_group("menu_settings_ui"):
		i.hide()


@rpc("any_peer")
func send_player_data(_name,id,current_claim=0):
	if not Global.mp_player_list.has(id):
		print(client_name," player adding player to list: " + str(id),_name," ",current_claim)
		Global.mp_player_list[id] = {
			"name": _name,
			"id": id,
			"current_claim": current_claim
		}
		if Global.mp_player_list[id].current_claim != 0:
			claims_picker_list[Global.mp_player_list[id].current_claim-1].emit_signal("toggled",true,false,Global.mp_player_list[id].name,Global.mp_player_list[id].id)
	if multiplayer.is_server():
		for i in Global.mp_player_list:
			send_player_data.rpc(Global.mp_player_list[i].name, i)

@rpc("any_peer")
func update_global_data(...arr):
	# map type
	if arr[0] is int:
		Global.map_type = arr[0]
	# Wall count
	if arr[1] is int:
		Global.wall_count = arr[1]
	# Fuel count
	if arr[2] is int:
		Global.fuel_count = arr[2]
	# Cap count
	if arr[3] is Array[int]:
		Global.cap_list = arr[3]
	# Claim set
	if arr[4] is Array[int]:
		Global.claim_list = arr[4]
	# Ai level
	if arr[5] is int:
		Global.ai_level = arr[5]
	# music type
	if arr[6] is int:
		Global.music_type = arr[6]
	# LMS setting
	if arr[7] is bool:
		Global.lms_enabled = arr[7]
	# Bran setting
	if arr[8] is bool:
		Global.bran_enabled = arr[8]
	if Global.mp_player_list.is_same_typed_value(arr[9]):
		Global.mp_player_list = arr[9]
	_ready(true)

func remove_player_data(id):
	if Global.mp_player_list.has(id):
		print(client_name," player removing player to list: " + str(id))
		if Global.mp_player_list[id].current_claim != 0:
			claims_picker_list[Global.mp_player_list[id].current_claim-1].emit_signal("toggled",false,Global.mp_player_list[id].name,Global.mp_player_list[id].id)
		Global.mp_player_list.erase(id)

var scene
@rpc("any_peer","call_local")
func start_game():
	timer.stop()
	scene = game_mp.instantiate()
	scene.get_child(1).mp_back_to_lobby.connect(end_game)
	get_tree().root.add_child(scene)
	self.hide()

func end_game():
	timer.start()
	get_tree().root.remove_child(scene)
	self.show()
	

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
	Global.mp_player_id = multiplayer.get_unique_id()
	send_player_data(client_label.text,Global.mp_player_id)
	
	for i in get_tree().get_nodes_in_group("menu_mp"):
		i.hide()
	for i in get_tree().get_nodes_in_group("menu_settings_ui"):
		i.show()
	
	peerUDP = PacketPeerUDP.new()
	peerUDP.bind(4433)
	
	is_hosting = true
	peerUDP.set_broadcast_enabled(true)
	update_broadcast_data()
	timer.start()



func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	
	is_joining = true


func _on_start_button_down():
	# Only the host should be able to start a game.
	if is_hosting:
		start_game.rpc()

func _on_singleplayer_pressed():
	get_tree().change_scene_to_file("res://levels/menu.tscn")

@onready var timer = $Timer

## This is like starting a host. How ever is ment to send data to those who are just now needing to see its data.[br]
## Its practaly updating its statis.
func update_broadcast_data():
	peerUDP.set_dest_address("255.255.255.255",4444)
	peerUDP.put_packet(str(Global.app_id).to_utf8_buffer())
	peerUDP.put_packet(server_name.to_utf8_buffer())
	peerUDP.put_packet(address.to_utf8_buffer())
	peerUDP.put_packet(str(port).to_utf8_buffer())
	
	peerUDP.set_dest_address(address_broadcast,4444)
	peerUDP.put_packet(str(Global.app_id).to_utf8_buffer())
	peerUDP.put_packet(server_name.to_utf8_buffer())
	peerUDP.put_packet(address.to_utf8_buffer())
	peerUDP.put_packet(str(port).to_utf8_buffer())
