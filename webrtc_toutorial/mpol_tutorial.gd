extends Node

var test_slider_value = 0
var connected = false

var lobbies = {}
var player_list = {}

## Handles what type of messge is being sent through the packets.
enum broadcast_msg {
	id,
	join,
	userConnected,
	userDisconnected,
	lobby,
	lobby_connection,
	candidate,
	offer,
	answer,
	checkIn
}
