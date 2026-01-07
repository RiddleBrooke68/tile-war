extends Node

const app_id = 0xF3459



# PREGENRATION
## Which map will be played.
var map_type = 1
# GENRATION
## Sets the number of wall tiles
var wall_count = 74
## Sets the number of fuel tiles
var fuel_count = 16
## Defines how meny capital of each claim that will be spwaned in, or removed.
var cap_list = [1,1,1,1]

# AI SETTINGS
#mp I want to make it so this is a choice between 0: disable claim, 1: enable claim as a bot, 2: enable claim as a player.
#mp [code] var claim_list = [2,1,1,1] [/code] this would be clean,
#mp [code] var claim_list = {"gre":2,"pur":1,"yel":1,","red":1} [/code] However, this would be clear. Maybe add a internal_name to claim data so you could use that. idk
## This sets what a claim's statis is apon a start of a match. [br][br]
## 0: disable claim,[br]1: enable claim as a bot,[br]2: enable claim as a player.
var claim_list : Array[int] = [2,1,1,1]
var claim_names : Array[String] = ["","","",""]
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
## Which type of music is it.
var music_type = 0
const music_list = ["res://audio/music/warning siren/warning siren.ogg","res://audio/music/wolfquest sounding ass/wolfquest.ogg"]
var music_vol = 10.0
var SFX_vol = 10.0
# MISC OPTIONS
## Last man standing[br]
## This makes it so if there is only one claim, the game will finaly end.
var lms_enabled = true
#Bran when there is something like the start of this line, then it involess this thing.
#Brian THANKS DAD.
## Battle random result[br]
## When enabled, the game will roll a d20 that has 
var bran_enabled = false

#multiplayer
signal mp_player_list_changed()

var mp_enabled = false
var mp_host = false
var mp_player_id = 0
var mp_player_list = {}: # peer_id:peer_data={
			#"name": _name,
			#"id": id,
			#"current_claim": 0}
			set(i):
				mp_player_list = i
				mp_player_list_changed.emit()

const mp_claims_colours = {
	claim_name_num.SPECTATOR: 	Color(0.44, 0.44, 0.44, 1.0),
	claim_name_num.GREENWICH: 	Color(0.403, 0.65, 0.28, 1.0),
	claim_name_num.PLUM_VALLEY: Color(0.568, 0.371, 0.64, 1.0),
	claim_name_num.YORK_STREET: Color(0.75, 0.722, 0.322, 1.0),
	claim_name_num.RIVER_SOLME: Color(0.74, 0.355, 0.426, 1.0)
}
