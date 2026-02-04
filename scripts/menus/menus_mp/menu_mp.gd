## LOCAL MULTIPAYER ONLY.
extends menu_class
class_name menu_mp_class
# LOCAL MULTIPLAYER SHIT
# IDK
@export var game_mp : PackedScene
@export var server_join : PackedScene
@export var player_plate : PackedScene
## This is the address that a player will connect to, or, if they are hosting, the address players will need.
@export var address = "192.168.17.140"
## (Used only when hosting)[br]
## Broadcast the IP to the lan through this IP, it also 
var address_broadcast = "192.168.17.255"
@export var port = 65535
##@deprecated Sort of. See [member Global.mp_host] for why.[br]
## This is set to true when the player hits host.
#var is_hosting = false
#var is_joining = false
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
@onready var player_browser = %player_browser

func _ready(is_updating=false):
	super(is_updating)
	Global.mp_enabled = true
	
	if "mp_name" in Global.cmd_args.keys():
		client_name = Global.cmd_args["mp_name"] 
	if "mp_svr_name" in Global.cmd_args.keys():
		server_name = Global.cmd_args["mp_svr_name"]
	if "mp_start_server" in Global.cmd_args.keys():
		Global.mp_server = true
		if client_name == "":
			client_name = "Host"
	# In the main menu, the ready function makes sure this is set to false, 
	# so after we run the class ready function, we make this true.
	
	if not is_updating:
		Global.mp_player_list_changed.connect(set_lobby_player_list)
		# Broadcasting
		peerUDP = PacketPeerUDP.new()
		peerUDP.bind(4444)
		
		multiplayer.peer_connected.connect(player_connected)
		multiplayer.peer_disconnected.connect(player_disconnected)
		multiplayer.connected_to_server.connect(connected_to_server)
		multiplayer.connection_failed.connect(connection_failed)
		multiplayer.server_disconnected.connect(server_disconnected)
		
		if server_name == "":
			server_name = str(OS.get_environment("COMPUTERNAME"))
		server_label.text = server_name
		client_label.text = client_name
		_on_client_name_text_changed(client_name)
		
		# Sets the port and ip
		set_id() # IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),IP.TYPE_IPV4)
		port = randi_range(1024,65535)
		server_ip_label.text = address
		server_port_label.text = str(port)
	
	if "mp_start_server" in Global.cmd_args.keys():
		_on_host_button_down()

func set_lobby_player_list():
	for i in get_tree().get_nodes_in_group("mp_lobby_name_plate"):
		player_browser.remove_child(i)
	for s in Global.mp_player_list.keys():
		var player_plate_inst = player_plate.instantiate()
		player_browser.add_child(player_plate_inst)
		player_plate_inst.set_nameplate(Global.mp_player_list[s].name,Global.mp_claims_colours[int(Global.mp_player_list[s].current_claim)])

@onready var green_picker = %green_picker
@onready var purple_picker = %purple_picker
@onready var yellow_picker = %yellow_picker
@onready var red_picker = %red_picker
@onready var claims_picker_list = [green_picker,purple_picker,yellow_picker,red_picker]

## MULTIPAYER ONLY.
@rpc("any_peer")
func _on_green_picker_toggled(toggled_on,mp_player_source=true,mp_name="",mp_id=0):
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
	set_lobby_player_list()

## MULTIPAYER ONLY.
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
	set_lobby_player_list()

## MULTIPAYER ONLY.
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
	set_lobby_player_list()

## MULTIPAYER ONLY.
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
	set_lobby_player_list()


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
	#client_label.text = new_text
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
	if new_text.to_int() in range(1024,65535):
		port = new_text.to_int()
	else:
		server_port_label.text = str(port)



# MP BUTTONS
## Called when a player connects to a server, regadless of client or server
func player_connected(id):
	#Global.mp_host = is_hosting
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
@rpc("any_peer")
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
	request_global_data.rpc_id(1,Global.mp_player_id)

## Called when the client fails connects to the server.
func connection_failed():
	print(client_name," Failed to connect")
	Global.mp_connected = false

@rpc("any_peer")
func server_disconnected():
	if not Global.mp_ended_sesion:
		print_rich(client_name," [color=red][b]NET_ERROR.001:[/b] It seems that a was just disconnected from the server.[/color]")
		OS.alert("Error: It seems that you were just disconnected from the server, try to rejoin if you can.", "NET_ERROR.001")
	else:
		print_rich(client_name," [color=red][b]NET_ERROR.002:[/b] You just closed the server.[/color]")
	Global.mp_connected = false
	peer = ENetMultiplayerPeer.new()
	Global.mp_player_id = 0
	Global.mp_player_list.clear()
	
	if not Global.mp_ended_sesion and get_tree() != null:
		for i in get_tree().get_nodes_in_group("menu_mp"):
			i.show()
		for i in get_tree().get_nodes_in_group("menu_settings_ui"):
			i.hide()
	else:
		Global.mp_ended_sesion = false

## When a player joins, each player will send back their info.
@rpc("any_peer")
func send_player_data(_name,id,current_claim=0):
	if not Global.mp_player_list.has(id):
		print(client_name," player adding player to list: " + str(id),_name," ",current_claim)
		Global.mp_player_list[id] = {
			"name": _name,
			"id": id,
			"current_claim": current_claim
		}
		set_lobby_player_list()
		if Global.mp_player_list[id].current_claim != 0:
			claims_picker_list[Global.mp_player_list[id].current_claim-1].emit_signal("toggled",true,false,Global.mp_player_list[id].name,Global.mp_player_list[id].id)
	if multiplayer.is_server():
		for i in Global.mp_player_list:
			send_player_data.rpc(Global.mp_player_list[i].name, i)

@rpc("any_peer")
func request_global_data(id):
	if Global.mp_host:
		var profile = profile_data.new()
		profile.settings = save_profile_data()
		#var dict = {
			#"map":Global.map_type,
			#"wall":Global.wall_count, "fuel":Global.fuel_count,
			#"cap":Global.cap_list, "claim":Global.claim_list, "ai":Global.ai_level,
			#"mus":Global.music_type,
			#"lms":Global.lms_enabled, "bran":Global.bran_enabled,
			#"cdan_e":Global.cdan_enabled, "cdan_d":Global.cdan_duration,
			#"blz_e":Global.blz_enabled,"blz_mr":Global.blz_move_requrement,
			#"players":Global.mp_player_list,"server_state":Global.mp_server
		#}
		load_profile_data.rpc_id(id,
					profile.settings)

## Loads a profile.
## Can be used to send game info to anyone joining.
@rpc("any_peer")
func load_profile_data(profile:Dictionary,refresh=true):
	super(profile,refresh)
	
	if profile.keys().has("server_state") and profile.server_state is bool:
		Global.mp_server = profile.server_state
	
	_ready(true)
	if profile.keys().has("players") and Global.mp_player_list.is_same_typed_value(profile.players):
		Global.mp_player_list = profile.players
		set_lobby_player_list()
		for i in Global.mp_player_list.keys():
			if Global.mp_player_list[i].current_claim != 0:
				claims_picker_list[Global.mp_player_list[i].current_claim-1].emit_signal("toggled",true,false,Global.mp_player_list[i].name,Global.mp_player_list[i].id)

func save_profile_data(mp_for_client=true) -> Dictionary:
	var data = super(mp_for_client)
	
	if mp_for_client:
		data["players"] = Global.mp_player_list
		
		data["server_state"] = Global.mp_server
	
	return data

func remove_player_data(id):
	if Global.mp_player_list.has(id):
		print(client_name," player removing player to list: " + str(id))
		if Global.mp_player_list[id].current_claim != 0:
			claims_picker_list[Global.mp_player_list[id].current_claim-1].emit_signal("toggled",false,Global.mp_player_list[id].name,Global.mp_player_list[id].id)
		Global.mp_player_list.erase(id)

var scene
@rpc("any_peer","call_local")
func start_game():
	print("game")
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
	
	Global.mp_host = true
	peerUDP.set_broadcast_enabled(true)
	update_broadcast_server_staius()
	timer.start()


func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	
	Global.mp_connected = true


func _on_start_button_down():
	# Only the host should be able to start a game.
	# UNLESS IT IS A SERVER.
	if Global.mp_host or Global.mp_server:
		start_game.rpc()

func _on_singleplayer_pressed():
	if Global.mp_host:
		update_broadcast_server_closed()
		server_disconnected.rpc()
		Global.mp_ended_sesion = true
		multiplayer.multiplayer_peer.close()#disconnect_peer(Global.mp_player_id)
	elif Global.mp_connected:
		player_disconnected.rpc(Global.mp_player_id)
		multiplayer.multiplayer_peer.close()
	Global.mp_player_list_changed.disconnect(set_lobby_player_list)
	super()


# BROADCASTING AND RESIVING


# UNUSED BUT IMPORTENT INFO
## The begining of any signal from a server, it WILL always start with this for any broadcast.
enum broadcast_form_start {
	## The resived Game Id, see [member Global.app_id] for what that number is.
	BRDCST_GAME_ID,
	## The resived name of the server that is being detected.
	BRDCST_SERVER_NAME,
	## The resived address of which the server derives from.
	BRDCST_SERVER_ADDRESS,
	## The resived port of which the server derives from.
	BRDCST_SERVER_PORT
}

## This simply starts the signal of a broadcast, and is requred before sending anything else.
## See [enum menu_mp_class.broadcast_form_start]
func broadcast_start_signal():
	peerUDP.put_packet(str(Global.app_id).to_utf8_buffer()) # First part of the a signal, the app_id.
	peerUDP.put_packet(server_name.to_utf8_buffer()) # Second part of a signal, the name of the server.
	peerUDP.put_packet(address.to_utf8_buffer())
	peerUDP.put_packet(str(port).to_utf8_buffer())

## This timer basicly just does a update server staius
@onready var timer = $Timer

##
enum broadcast_form_staius {
	## The resived Game Id, see [member Global.app_id] for what that number is.
	BRDCST_GAME_ID,
	## The resived name of the server that is being detected.
	BRDCST_SERVER_NAME,
	## The resived address of which the server derives from.
	BRDCST_SERVER_ADDRESS,
	## The resived port of which the server derives from.
	BRDCST_SERVER_PORT,
	## The resived lobby size, meaning how meny player are in a server.
	BRDCST_SERVER_LOBBY_SIZE
}

## This is like starting a host. However is ment to send data to those who are just now needing to see its data.[br]
## Its practaly updating its staius.
## Uses [enum menu_mp_class.broadcast_form_start] as its framework for how it sends this info.
func update_broadcast_server_staius():
	peerUDP.set_dest_address("255.255.255.255",4444)
	broadcast_start_signal()
	peerUDP.put_packet("{0} Players".format([Global.mp_player_list.size()]).to_utf8_buffer())
	
	peerUDP.set_dest_address(address_broadcast,4444)
	broadcast_start_signal()
	peerUDP.put_packet("{0} Players".format([Global.mp_player_list.size()]).to_utf8_buffer())


##
enum broadcast_form_end {
	## The resived Game Id, see [member Global.app_id] for what that number is.
	BRDCST_GAME_ID,
	## The resived name of the server that is being detected.
	BRDCST_SERVER_NAME,
	## The resived address of which the server derives from.
	BRDCST_SERVER_ADDRESS,
	## The resived port of which the server derives from.
	BRDCST_SERVER_PORT,
	## The resived for when a server ends.
	BRDCST_SERVER_CLOSED
}

func update_broadcast_server_closed():
	peerUDP.set_dest_address("255.255.255.255",4444)
	broadcast_start_signal()
	peerUDP.put_packet("closed".format([Global.mp_player_list.size()]).to_utf8_buffer())
	
	peerUDP.set_dest_address(address_broadcast,4444)
	broadcast_start_signal()
	peerUDP.put_packet("closed".format([Global.mp_player_list.size()]).to_utf8_buffer())


# Read server signals.
## When it starts reading a signal it will atempt to read it.
var resiving_mesge = false
## This counts what part of the signal that is being resive is.
var resive_digit = 0

# Start broadcast info.
## See [enum menu_mp_class.broadcast_form_start]
var svr_mp_game_id = ""
## See [enum menu_mp_class.broadcast_form_start]
var svr_mp_name = ""
## See [enum menu_mp_class.broadcast_form_start]
var svr_mp_address = ""
## See [enum menu_mp_class.broadcast_form_start]
var svr_mp_port = ""


var svr_mp_lobby_size = ""

var svr_mp_closed = ""
## This only is checking for server signals it seems.
func _process(_delta):
	if not Global.mp_host and not Global.mp_connected:
		#var _s = peerUDP.get_available_packet_count()
		if peerUDP.get_available_packet_count() > 0:
			var array_bytes = peerUDP.get_packet()
			var game_id = array_bytes.get_string_from_ascii()
			print("Received message: ", game_id)
			# BASIC DATA
			# The first part of a server signal.
			# This tells us if the signal is coming from
			if game_id.to_int() == Global.app_id and resive_digit == broadcast_form_start.BRDCST_GAME_ID:
				resiving_mesge = true
				svr_mp_game_id = game_id
			
			# The second part of a server signal.
			# Check if the server is currently being seen.
			var list_of_servers_names = [""]
			for i in get_tree().get_nodes_in_group("server_connection"):
				list_of_servers_names.append(i.server_name)
			# The name of the server.
			if resive_digit == broadcast_form_start.BRDCST_SERVER_NAME:
				svr_mp_name = game_id
			
			# The third part of a server signal.
			# Check if the server is currently being seen.
			var list_of_servers_ip = [""]
			for i in get_tree().get_nodes_in_group("server_connection"):
				list_of_servers_ip.append(i.server_address)
			# The address of the server
			if game_id.is_valid_ip_address() and resive_digit == broadcast_form_start.BRDCST_SERVER_ADDRESS:
				svr_mp_address = game_id
			
			# The fourth part of a server signal.
			# Check if the server is currently being seen.
			var list_of_servers_port = [""]
			for i in get_tree().get_nodes_in_group("server_connection"):
				list_of_servers_port.append(i.server_port)
			if game_id.to_int() in range(1024,65535) and resive_digit == broadcast_form_start.BRDCST_SERVER_PORT:
				svr_mp_port = game_id
			
			# The fith part of a server signal, and also where we start seeing a drift in the data depending on how it its.
			# This is if the signal is updating the server info.
			if not game_id in ["","closed"] and resive_digit == broadcast_form_staius.BRDCST_SERVER_LOBBY_SIZE:
				svr_mp_lobby_size = game_id
			elif game_id == "closed" and resive_digit == broadcast_form_end.BRDCST_SERVER_CLOSED:
				svr_mp_closed = game_id
			
			if svr_mp_game_id.to_int() == Global.app_id:
				# If this server signal matches a hosting signal shape, then it is a open server to join to.
				if (	not (svr_mp_name in list_of_servers_names or svr_mp_address in list_of_servers_ip and svr_mp_port.to_int() in list_of_servers_port) # ALL DATA MUST MATCH ANOTHER SERVER TO NOT FIRE
						and svr_mp_closed != "closed"
						and svr_mp_address.is_valid_ip_address() 
						and svr_mp_port.to_int() in range(1024,65535) 
						and svr_mp_lobby_size != ""
						):
					var server_panel = server_join.instantiate()
					server_panel.server_name = svr_mp_name
					server_panel.server_address = svr_mp_address
					server_panel.server_port = svr_mp_port.to_int()
					server_browser.add_child(server_panel)
					server_panel.selected_server.connect(select_server)
				
				# If the server exists in the browser
				elif (	(svr_mp_name in list_of_servers_names or svr_mp_address in list_of_servers_ip and svr_mp_port.to_int() in list_of_servers_port) 
						and svr_mp_closed != "closed"
						and svr_mp_lobby_size != ""
						):
					var server_panel : BoxContainer
					for i in get_tree().get_nodes_in_group("server_connection"):
						if svr_mp_name == i.server_name and svr_mp_address == i.server_address and svr_mp_port.to_int() == i.server_port:
							server_panel = i
					if server_panel != null:
						server_panel.server_lobby_size = svr_mp_lobby_size
				
				elif (	(svr_mp_name in list_of_servers_names or svr_mp_address in list_of_servers_ip and svr_mp_port.to_int() in list_of_servers_port) 
						and svr_mp_closed != "closed"
						):
					var server_panel : BoxContainer
					for i in get_tree().get_nodes_in_group("server_connection"):
						if svr_mp_name == i.server_name and svr_mp_address == i.server_address and svr_mp_port.to_int() == i.server_port:
							server_panel = i
					if server_panel != null:
						server_panel.free()
			
			resive_digit += 1
		elif resiving_mesge:
			resiving_mesge = false
			resive_digit = 0
			svr_mp_game_id = ""
			svr_mp_name = ""
			svr_mp_address = ""
			svr_mp_port = ""
			svr_mp_lobby_size = ""
