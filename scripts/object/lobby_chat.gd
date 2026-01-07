extends BoxContainer

var chat_log = "":
	set(new):
		chat_log = new
		chat_box.text = chat_log

@onready var chat_box = %chat_box
@onready var chat_mode = %chat_mode
@onready var chat_input = %chat_input

@rpc("any_peer","call_local")
func mp_lobby_print_chatmsg(chat_sender:String,chat_msg="",chat_sender_colour=Color(1.0, 1.0, 1.0, 1.0)):
	var chat_sender_colour_hex = chat_sender_colour.to_html()
	chat_log += "[color={2}][b]{0}:[/b][/color] {1}\n".format([chat_sender,chat_msg,chat_sender_colour_hex])
	chat_input.text = ""

func _on_chat_input_text_submitted(new_text):
	mp_lobby_print_chatmsg.rpc(Global.mp_player_list[Global.mp_player_id].name,new_text,Global.mp_claims_colours[Global.mp_player_list[Global.mp_player_id].current_claim])
