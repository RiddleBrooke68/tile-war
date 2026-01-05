extends BoxContainer

signal selected_server(select_name:String,select_ip:String,select_port:int)

@export var server_name = ""
@export var server_address = ""
@export var server_port = 1

@onready var server_connect_point = $server_connect_point
@onready var server_ip_text = $server_input/server_ip
@onready var server_port_text = $server_input/server_port

func _ready():
	server_connect_point.text = server_name
	server_ip_text.text = server_address
	server_port_text.text = str(server_port)

func selected():
	selected_server.emit(server_name,server_address,server_port)
