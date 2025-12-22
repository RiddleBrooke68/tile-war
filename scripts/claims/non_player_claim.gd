extends ClaimData
class_name NonPlayerClaim


func claim_surounding_tiles(available:Array[tile_data]) -> Vector2i:
	var target_list : tile_data
	var opimal : Array[tile_data]
	if Global.ai_level == 1:
		opimal = get_best_paths(available)
	elif Global.ai_level == 0:
		opimal = available
	if opimal.size() != 0:
		target_list = opimal[randi_range(0,opimal.size()-1)]
	print("{0}, had picked a path with a value of {1}, coords: {2}".format([name,target_list.move_to_value,target_list.coords]))
	return target_list.coords

func get_best_paths(available:Array[tile_data]) -> Array[tile_data]:
	var highest_value = 0
	for i in available.size():
		if available[i].move_to_value > highest_value:
			highest_value = available[i].move_to_value
	var remove = func(item:tile_data)->bool:
		return item.move_to_value >= highest_value
	available = available.filter(remove)
	return available
