extends Resource
class_name ClaimData

signal changed_info

@export var name = "":
	set(n):
		name = n
		changed_info.emit()
@export_range(1,4) var claim_colour = 1
@export var moves = 0:
	set(n):
		moves = n
		changed_info.emit()
@export var claim_panel : Texture
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
