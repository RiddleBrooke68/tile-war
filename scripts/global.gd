extends Node

## This represents the game's id, it uses this to make sure that it is comunicating with another client.
const app_id = 0xF3459

## Controls which grid the player is using.
var grid_style = 0

# PREGENRATION

var grid_maps : Array[map_data] = [
	preload("res://Resources/maps/no_genration.tres"),
	preload("res://Resources/maps/standoff.tres"),
	preload("res://Resources/maps/fortress.tres"),
	preload("res://Resources/maps/surrounded.tres"),
	preload("res://Resources/maps/big_n_empty.tres"),
	preload("res://Resources/maps/aqua.tres")
	]
## Which map will be played.
var map_type = 1
# GENRATION
## Sets the number of wall tiles
var wall_count = 74
## Sets the number of fuel tiles
var fuel_count = 16
## Sets how many sea tiles there are, and sea shells.
var sea_count = 16
## Defines how meny capital of each claim that will be spwaned in, or removed.
var cap_list = [2,2,2,2]


# AI SETTINGS
#mp I want to make it so this is a choice between 0: disable claim, 1: enable claim as a bot, 2: enable claim as a player.
#mp [code] var claim_list = [2,1,1,1] [/code] this would be clean,
#mp [code] var claim_list = {"gre":2,"pur":1,"yel":1,","red":1} [/code] However, this would be clear. Maybe add a internal_name to claim data so you could use that. idk
## This sets what a claim's statis is apon a start of a match. [br][br]
## 0: disable claim,[br]1: enable claim as a bot,[br]2: enable claim as a player.
var claim_list : Array[int] = [2,1,1,1]
## Contains the any name that a player has inputed into the game. :/
var claim_names : Array[String] = ["","","",""]
## This Silly looking thing cost me 2 bloody days I won't get back. GUESS IT WORKS NOW.[br][br]
## It also controls who will spawn in, green, purple, yellow, red, or blue. Because why the hell not?
var claim_colours : Array[int] = [1,2,3,4]
## Each name is so have a more clear indcator of who is who.
enum claim_name_num {
	## This is 0 or with some arrays -1, this means they are not a player.[br] MP Exlusive.
	SPECTATOR, 
	## 1 or in an array: 0.
	GREENWICH, 
	## 2 or in an array: 1.
	PLUM_VALLEY, 
	## 3 or in an array: 2.
	YORK_STREET, 
	## 4 or in an array: 3.
	RIVER_SOLME, 
}
## Removes player if disabled[br]
##@deprecated: Use [member claim_list] instead.
var player_enabled = true
## Removes purple if disabled[br]
##@deprecated: Use [member claim_list] instead.
var purple_enabled = true
## Removes yellow if disabled[br]
##@deprecated: Use [member claim_list] instead.
var yellow_enabled = true
## Removes red if disabled[br]
##@deprecated: Use [member claim_list] instead.
var red_enabled = true
# AI DIFCATY
## Sets how hard each the ai will be.
var ai_level = 1:
	set(value):
		if value == 1:
			dist = 2
		elif value == 2:
			dist = 3
		ai_level =  value
var dist = 2

# MUSIC OPTIONS
## A list of every type of musical style that the game uses.
enum music_style_list {
	basic, ## Built in: This song play in only on track, No need for dynamics.
	dynamic, ## Built in: This song plays using the battle_music_manger, changing the music based on the current game.
	md_basic, ## Modded: A modded in version of basic.
	md_dynamic ## Modded: A modded in version of dynamic.
}
## Which type of music is it.
var music_type = 0
## [center][b] Each entry is a Dict that can contain these varables: [/b][/center][br][br]
## [b]music_name:[/b] The name of the music.[br]
## [b]music_style:[/b] The style of music. See [enum music_style_list][br]
## [b]music_path:[/b] The path to said music.
var music_list = [
	{
		"music_name":"warning siren",
		"music_style":music_style_list.basic,
		"music_path":"res://audio/music/placeholders/warning siren/warning siren.ogg"
	},
	{
		"music_name":"wolfquest",
		"music_style":music_style_list.basic,
		"music_path":"res://audio/music/placeholders/wolfquest sounding ass/wolfquest.ogg"
	},
	{
		"music_name":"33 thousand tiles under the blue",
		"music_style":music_style_list.basic,
		"music_path":"res://audio/music/placeholders/33 thousand tiles under the blue/33 thousand tiles under the blue.ogg"
	},
	{
		"music_name":"battle_2",
		"music_style":music_style_list.dynamic,
		"music_path":"res://Resources/dynamic_music/battle_2.tres"
	},
	]
var music_vol = 10.0
var SFX_vol = 10.0
# MISC OPTIONS
## Last man standing[br]
## This makes it so if there is only one claim, the game will finaly end.
var lms_enabled = true
#Bran when there is something like the start of this line, then it involess this thing.
#Brian: THANKS DAD.
## Battle random result[br]
## When enabled, the game will roll a d20 that has 
var bran_enabled = false
## Capatial Protection[br]
## When enabled, the game will make it block any attept of taking any more tiles from a claim who lost a capital, that is untill after a set amount of moves are taken.
var cdan_enabled = true
## Capatial Protection Duration
var cdan_duration = 10
## Capatial capture protection duration
var cdan_capture_duration = 5
## Bliz attack
var blz_enabled = true
var blz_move_requrement = 5
## Capatial last stand
var cls_enabled = true
## This controls how strong it is.
var cls_boost = 2
## Fog of war
var fow_enabled = false
## Sight in the fog.
var fow_sight = 3
## Allows claims to move off of a coastal tile the have tiles near.
var coastmove_enabled = true
## The cost of
var coastmove_movement_cost = 3


# Moves settings
# Tiles
## This divides the intial moves gained by tiles claimed.
var moves_tile_int_reduction_boost = 2
## This is the limit to stop the intial boost from going too high.
var moves_tile_int_lim_boost = 15
## This divides the second moves gained by tiles claimed. 
var moves_tile_second_reduction_boost = 5
## This limits the the second boost to moves gained by tiles claimed.
var moves_tile_second_lim_boost = 20
# FUEL
## This divides the intial moves gained by tiles claimed.
var moves_fuel_reduction_boost = 2
## This is the limit to stop the intial boost from going too high.
var moves_fuel_lim_boost = 5
# TURNS
## This divides the intial moves gained by tiles claimed.
var moves_turn_reduction_boost = 2
## This is the limit to stop the intial boost from going too high.
var moves_turn_lim_boost = 10



#multiplayer
signal mp_player_list_changed()

enum mp_msg {
	id,
	join,
	userConnected,
	userDisconnected,
	lobby,
	lobby_host,
	lobby_join,
	lobby_update,
	lobby_close,
	candidate,
	offer,
	answer,
	checkIn
}

var mp_enabled = false
var mp_host = false
var mp_server = false
var mp_connected = false
var mp_player_id = 0
var mp_player_color = 0
var mp_player_list = {}: # peer_id:peer_data={
			#"name": _name,
			#"id": id,
			#"current_claim": 0}
			set(i):
				mp_player_list = i
				mp_player_list_changed.emit()
var mp_ended_sesion = false

const mp_claims_colours = {
	claim_name_num.SPECTATOR: 	Color(0.44, 0.44, 0.44, 1.0),
	claim_name_num.GREENWICH: 	Color(0.403, 0.65, 0.28, 1.0),
	claim_name_num.PLUM_VALLEY: Color(0.568, 0.371, 0.64, 1.0),
	claim_name_num.YORK_STREET: Color(0.75, 0.722, 0.322, 1.0),
	claim_name_num.RIVER_SOLME: Color(0.74, 0.355, 0.426, 1.0)
}

# MULTIPLAYER ONLINE

var mpol_svr_users = {}
var mpol_svr_lobbies = {}
## Checks if the player is the server host.
var mpol_svr_host = false

var mpol_clnt_lobbies = {}
var mpol_clnt_connected = false


# START UP
## Record what is placed into the commands on start up
var cmd_args = {}

func _ready():
	for cmdline in OS.get_cmdline_args():
		if cmdline.contains("="):
			var key_value = cmdline.split("=")
			cmd_args[key_value[0].trim_prefix("--")] = key_value[1]
		else:
			# Options without an argument will be present in the dictionary,
			# with the value set to an empty string.
			cmd_args[cmdline.trim_prefix("--")] = ""
	if "music_type" in cmd_args.keys():
		if int(cmd_args["music_type"]) >= 0 and int(cmd_args["music_type"]) < music_list.size():
			music_type = int(cmd_args["music_type"])
	if "map_type" in cmd_args.keys():
		map_type = cmd_args[map_type]
