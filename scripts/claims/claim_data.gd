extends Resource
class_name ClaimData

signal changed_info

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
		moves = n
		changed_info.emit()
## This is what panel that will be used if the claim is alive. See [member ClaimDataPanel.fallback_panel] and [member ClaimDataPanel.dead_panel]
@export var claim_panel : Texture
## If multiplayer is active, then is makes sure that players don't control other players.
@export var claim_mp_ip_linked : int
@export_group("Unused info")
##@deprecated: This will never apear in game and is used only as to give me thoughts on how they work.
@export_multiline var info : String
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
var claim_had_turn = false:
	set(n):
		claim_had_turn = n
		changed_info.emit()

func refresh(turn_num):
	@warning_ignore("integer_division", "narrowing_conversion")
	moves = mini(tile_size / 2,maxi(tile_size / 10,15)) + fuel_count + turn_num # + pow(tile_size,1/2)

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
