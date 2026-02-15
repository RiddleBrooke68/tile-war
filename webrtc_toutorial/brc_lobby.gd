## @experimental
## This is for online multiplayer, EGNORE IT
##@deprecated
## All of the brc code, are and WILL, be unused.
## I don't need to say this but this shit, just does not fucking work.
extends RefCounted
class_name brc_testing_lobby

var host_id : int
var players : Dictionary = {}

func _init(id):
	host_id = id

func add_player(id,p_name):
	players[id] = {
		"name":p_name,
		"id":id,
		"index":players.size() + 1
	}
	return players[id]
