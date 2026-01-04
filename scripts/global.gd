extends Node

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
## Sets how hard each the ai will be.
var ai_level = 1:
	set(value):
		if value == 1:
			dist = 2
		elif value == 2:
			dist = 3
		ai_level =  value
var dist = 2

## Last man standing
var lms_enabled = true
## Which type of music is it.
var music_type = 0
const music_list = ["res://audio/music/warning siren/warning siren.ogg","res://audio/music/wolfquest sounding ass/wolfquest.ogg"]
var music_vol = 10.0
var SFX_vol = 10.0
