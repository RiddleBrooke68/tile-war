extends Resource
class_name tile_data


@export var coords : Vector2i
## the tile_data, 0 means empty tile, 1 means enemy tile, 2 is player claim, and 3 is impassable, and -1 means it anavilable
@export var type = 0
## Just so the player knows what is a tile, fuel, or cappital
@export var tile_type = "claim"
@export var available = false

@export var opposite_claim_data : ClaimData
@export var opposite_claim = ""
@export var oppose_points = 0
@export var oppose_fuel = 0

@export var points = 0
@export var fuel = 0

@export var final_score = 0
@export var cap_list = []

@export var move_to_value = 0
var move_to_value_comp = ""

var empty_compile = ""
var enemy_compile = ""
var attack_copile = ""
var player_compile = ""
var boost_compile = ""
var score_compile = ""
var reach_compile = ""


const empty_text = "This is a empty {tile_type} tile\n"
const enemy_text = "This is a enemy claim from:\n[b]{opposite_claim}[/b]\nThey get:\n      [b]{oppose_points} surrounding points[/b]\n      [b]{oppose_fuel} fuel points[/b]\n"
const attack_text = "You get:\n      [b]{points} surrounding points[/b]\n      [b]{fuel} fuel points[/b]\n"
const boost_text = "The attatcker also gets:\n  [b]+1 attack boost[/b]\n"
const boost_cap_text = "  [b]+{cap_linked} capital boost[/b]\n--------------\n"
const score_text = "This ends up with a score of: [b]{br_score}[/b]\n"
const player_text = "This is Your {tile_type} tile\n"
const wall_text = "This is impassable."

const reach = "You can{available} take this tile."

func get_info() -> String:
	#if not available:
		#reach_compile = reach.format({"available":"'t"})
	#else:
		#reach_compile = reach.format({"available":""})
	reach_compile = reach.format({"available":"'t"}) if not available else reach.format({"available":""})
	move_to_value_comp = str(move_to_value) if move_to_value > 0 else ""
	empty_compile = empty_text.format({"tile_type":tile_type})
	enemy_compile = enemy_text.format({"opposite_claim":opposite_claim,"oppose_points":oppose_points,"oppose_fuel":oppose_fuel})
	attack_copile = attack_text.format({"points":points,"fuel":fuel})
	score_compile = score_text.format({"br_score":final_score})
	player_compile = player_text.format({"tile_type":tile_type})
	boost_compile = boost_cap_text.format({"cap_linked":cap_list.size(),"cap_list":cap_list})
	if type == 0:
		return ("{0}, {1}\n".format([coords,move_to_value_comp])+empty_compile+reach_compile)
	elif type == 1:
		return ("{0}, {1}\n".format([coords,move_to_value_comp])+enemy_compile+attack_copile+boost_text+boost_compile+score_compile+reach_compile)
	elif type == 2:
		return ("{0}, {1}\n".format([coords,move_to_value_comp])+player_compile+attack_copile+boost_text)
	elif type == 3:
		return ("{0}, {1}\n".format([coords,move_to_value_comp])+wall_text+empty_compile)
	else:
		return ""
