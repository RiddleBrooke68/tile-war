extends Resource
class_name profile_data

@export var profile_name = ""
## Used to discribe what this does.
@export_multiline var profile_discription = ""
## This controls if it is interal (1), or external (0). It does not get controled outside of that.
var profile_type = 0
var profile_path = ""

@export var settings = {
	"map":1,
	"wall":74, "fuel":16,
	"cap":[1,1,1,1], "ai":1,
	"lms":true, "bran":false,
	"cdan_e":true, "cdan_d":10,"cdan_cd":5,
	"blz_e":true,"blz_mr":10,
	"move_settings":{
		"tile_int_r":2,"tile_int_l":10,
		"tile_sec_r":5,"tile_sec_l":20,
		"fuel_r":2,"fuel_l":5,
		"turn_r":2,"turn_l":10
		}
}
