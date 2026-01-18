## @experimental
## This is for online multiplayer, EGNORE IT
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
