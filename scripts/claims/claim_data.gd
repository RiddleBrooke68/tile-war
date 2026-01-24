extends Resource
class_name ClaimData

signal changed_info
signal move_made

## What will game present as their defualt name
@export var name = "":
	set(n):
		name = n
		changed_info.emit()
## What colour do they asine to. Note that 0 is unclaimed and 5 is unused.
@export_range(1,5) var claim_colour = 1
## How meny moves do they get.
@export var moves = 0:
	set(n):
		if n <= moves - 1:
			move_made.emit()
		moves = n
		changed_info.emit()
## This is what panel that will be used if the claim is alive. See [member ClaimDataPanel.fallback_panel] and [member ClaimDataPanel.dead_panel]
@export var claim_panel_normal : Texture
## Use when the player is in danger mode, where one their capatials have been taken. If left empty, it will defaut to [member ClaimData.claim_panel_normal], see that also for more info.
@export var claim_panel_danged : Texture
## If multiplayer is active, then is makes sure that players don't control other players.
@export var claim_mp_ip_linked : int = 0
@export_group("Unused info")
##@deprecated: This will never apear in game and is used only as to give me thoughts on how they work.
@export_multiline var info : String
@export var orginal_claim : ClaimData
var fuel_count = 0:
	set(n):
		fuel_count = n
		changed_info.emit()
var tile_size = 0:
	set(n):
		tile_size = n
		changed_info.emit()
var capatal_tile : Array[Vector2i]:
	set(n):
		capatal_tile = n
		changed_info.emit()
var claim_dead = false:
	set(n):
		claim_dead = n
		changed_info.emit()
var claim_active = false:
	set(n):
		claim_active = n
		changed_info.emit()
var claim_dangered = 0:
	set(n):
		claim_dangered = n
		changed_info.emit()
var claim_had_turn = false:
	set(n):
		claim_had_turn = n
		changed_info.emit()
#var claim_made_move = false:
	#set(n):
		#claim_made_move = n
		#changed_info.emit()

func depleate_danger_value():
	if claim_dangered - 5 >= 0:
		claim_dangered -= 5

## This is where movement is calulated. 
func refresh(turn_num) -> int:
	@warning_ignore("integer_division", "narrowing_conversion")
	moves = (
		mini(
			tile_size / Global.moves_tile_int_reduction_boost, # With default settings. For every two tiles you own, you gain +1 moves.
			maxi(
				mini(
					tile_size / Global.moves_tile_second_reduction_boost, # With default settings. For every ten tiles you own, you gain +1 moves.
					Global.moves_tile_second_lim_boost), # With a max of 30
				Global.moves_tile_int_lim_boost)) # With a max of 15
		+ mini(
			fuel_count/Global.moves_fuel_reduction_boost, # With default settings. For every fuel tile you own, you gain +1 moves.
			Global.moves_fuel_lim_boost) # With a max of 10
		+ mini(
			turn_num/Global.moves_turn_reduction_boost, # With default settings. Every turn you gain +1 moves.
			Global.moves_turn_lim_boost)) # With a max of 10
	print("{0} has: {1}".format([name,moves]))
	return moves

func print_data():
	print("\n------------------")
	print(name)
	print("claim_colour", claim_colour)
	print("tile_size", tile_size)
	print("capatal_tile", capatal_tile)
	

func get_data():
	return "----------------\n
{0} have
{1} tiles, {2} fuel tiles,
and {3} capitals\n".format([name,tile_size,fuel_count,capatal_tile.size()])
