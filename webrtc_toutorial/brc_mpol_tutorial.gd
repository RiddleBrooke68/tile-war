##@deprecated
## All of the brc code, are and WILL, be unused.
## I don't need to say this but this shit, just does not fucking work.
extends Node

var test_slider_value = 0
var connected = false

var lobbies = {}
## The player's lobby, client side
var player_list = {}

## Handles what type of messge is being sent through the packets.
enum broadcast_msg {
	id, # 0
	join, # 1
	userConnected, # 2
	userDisconnected, # 3
	lobby, # 4
	lobby_connection, # 5
	candidate, # 6
	offer, # 7
	answer, # 8
	checkIn # 9
}
