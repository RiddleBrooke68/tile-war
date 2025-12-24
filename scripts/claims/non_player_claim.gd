extends ClaimData
class_name NonPlayerClaim

## If it sees a fuel tile, it goes for it. This weighs that. See [method board.search_surounding_tiles]
@export var fuel_beeline = 2
## If it sees a opening in an enemy defence, it takes it. This weighs that. See [method board.search_surounding_tiles]
@export var stratigic_beeline = 1
## If it sees anything that isn't empty, it goes for it. This weighs that. See [method board.search_surounding_tiles]
@export var blindless_beeline = 0
## If it sees its teratory, it goes for it. This weighs that. See [method board.search_surounding_tiles]
@export var teratory_beeline = -1
## If it sees a capital, it goes for it. This weighs that. See [method board.search_surounding_tiles]
@export var capital_beeline = 0
## If it sees a wall, it goes for it. This weighs that. See [method board.search_surounding_tiles]
@export var wall_beeline = 0

func claim_surounding_tiles(available:Array[tile_data]) -> tile_data:
	var target_list : tile_data
	var opimal : Array[tile_data]
	if Global.ai_level >= 1:
		opimal = get_best_paths(available)
	elif Global.ai_level == 0:
		opimal = available
	if opimal.size() != 0:
		target_list = opimal[randi_range(0,opimal.size()-1)]
	if target_list != null:
		print("{0}, had picked a path with a value of {1}, coords: {2}".format([name,target_list.move_to_value,target_list.coords]))
	return target_list

func get_best_paths(available:Array[tile_data]) -> Array[tile_data]:
	var highest_value = -900
	for i in available.size():
		if available[i].move_to_value > highest_value:
			highest_value = available[i].move_to_value
	var remove = func(item:tile_data)->bool:
		return item.move_to_value >= highest_value
	available = available.filter(remove)
	return available
