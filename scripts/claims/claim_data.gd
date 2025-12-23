extends Resource
class_name ClaimData

@export var name = ""
@export_range(1,4) var claim_colour = 1
@export var moves = 0
var fuel_count = 0
var tile_size = 0
var capatal_tile : Array[Vector2i]
var claim_dead = false

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
and {3} capitals\n".format([name,tile_size,fuel_count])
