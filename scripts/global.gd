extends Node

## Sets the number of wall tiles
var wall_count = 74
## Sets the number of fuel tiles
var fuel_count = 16
## Removes player if disabled
var player_enabled = true
## Removes purple if disabled
var purple_enabled = true
## Removes yellow if disabled
var yellow_enabled = true
## Removes red if disabled
var red_enabled = true
var ai_level = 1:
	set(value):
		if value == 1:
			dist = 2
		elif value == 2:
			dist = 3
		ai_level =  value
var dist = 2
var cap_list = [1,1,1,1]
## Last man standing
var lms_enabled = true
## Which type of music is it.
var music_type = 0
const music_list = ["res://audio/music/warning siren/warning siren.ogg","res://audio/music/wolfquest sounding ass/wolfquest.ogg"]
var music_vol = 10.0
var SFX_vol = 10.0
