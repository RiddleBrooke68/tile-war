## The script that just controls how the board works.
extends PanelContainer
class_name board
## Tells the game manger that the game state has changed
signal game_state_change

signal tile_info(data:tile_data)

## Controls the impasable tile count
@export var impasable_tile_count = 15

## Controls the fuel tile count
@export var fuel_tile_count = 10

## The main grid. 7x10
@onready var main_grid = $main_grid
## The overlay thats to show the player what their clicking.
@onready var overlay_grid = $overlay_grid


@onready var game = $"../.."

## Watches for if the mouse is on the board or not.
var hovered = false

## makes it so it cant be used.
var lock_mode = false

var off_input = false

var enabled_claims = [true, true, true, true]

## The grid_coords where the mouse is.
var grid_coords : Vector2i


## For game sounds. (CURRENTLY USING SOUNDS FROM GOD MACHINE)
var sound : AudioStreamPlayer

var lot : Vector4i

func _ready():
	enabled_claims.clear()
	enabled_claims.append_array([
		Global.player_enabled,
		Global.purple_enabled,
		Global.yellow_enabled,
		Global.red_enabled])
	sound = AudioStreamPlayer.new()
	add_child(sound)
	
	var set_of_grid : Array[Vector2i] = main_grid.get_used_cells()
	var maxx = set_of_grid.max()
	var minn = set_of_grid.min()
	lot = Vector4i(maxx.x,maxx.y,minn.x,minn.y)
	print(lot)
	var rcoord : Callable = func(dot=false,wall=false)->Vector2i:
		var thing
		var spot = false
		while not spot:
			thing = Vector2i(randi_range(lot.z,lot.x),randi_range(lot.w,lot.y))
			spot = check_tile_neutralty(thing,dot,wall)
		return thing
	for i in range(0,4):
		if enabled_claims[i]:
			on_claim_tile(rcoord.call(),i+1,1,false)
	while ( check_claim_tile_type_count(0,1) < Global.wall_count
			or
			check_claim_tile_type_count(0,3) < Global.fuel_count):
		for i in range(check_claim_tile_type_count(0,1),Global.wall_count):
			on_claim_tile(rcoord.call(false,true),0,1,false,true)
		for i in range(check_claim_tile_type_count(0,3),Global.fuel_count):
			on_claim_tile(rcoord.call(true),0,3,false,true)
	print("wall: ",check_claim_tile_type_count(0,1))
	print("fuel: ",check_claim_tile_type_count(0,3))


func _process(_delta):
	if hovered:
		# Get mouse position on grid.
		var mouse_pos = get_global_mouse_position()
		overlay_grid.clear()
		grid_coords = overlay_grid.local_to_map(overlay_grid.to_local(mouse_pos))
		
		# See if tile is claimable
		lock_mode = not check_tile_claimably(grid_coords,1,true)
		
		# Set the overlay
		var type = 2 if lock_mode or off_input else 0
		if lock_mode:
			overlay_grid.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			overlay_grid.modulate = Color(0.5, 0.5, 0.5, 0.255)
		overlay_grid.set_cell(grid_coords, 0, Vector2i(1,type))


## Gets if the mouse enters the board. [member board.hovered]
func _on_mouse_entered():
	hovered = true

## Gets if the mouse leaves the board. [member board.hovered]
func _on_mouse_exited():
	hovered = false

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and not (lock_mode or off_input):
			on_claim_tile(grid_coords,1)
			sound.stream = load("res://audio/FX/left click sound.mp3") as AudioStream
		elif lock_mode:
			sound.stream = load("res://audio/FX/right click sound.mp3") as AudioStream
		sound.play()

## Sets a tile on the main board.
func on_claim_tile(coords:Vector2i,claim:int,type:int=-1,update=true,terain=false):
	var picked_tile : TileData = main_grid.get_cell_tile_data(coords)
	if picked_tile.get_custom_data("type") == 1 and type == -1:
		type = 3
	elif picked_tile.get_custom_data("type") == 3 and type == -1:
		type = 3
	elif type == -1:
		type = 0
	main_grid.set_cell(coords,0,Vector2i(claim,type))
	if type == 1 and not terain:
		var neighbors = main_grid.get_surrounding_cells(coords)
		for neighbor in neighbors:
			picked_tile = main_grid.get_cell_tile_data(neighbor)
			if not picked_tile == null:
				on_claim_tile(neighbor,claim,0,update)
	if update:
		game_state_change.emit()

## Checks if a tile can be claimed. Returns true if claimable.
func check_tile_claimably(coords:Vector2i,claim:int,test_suroundings=false) -> bool:
	var tile = tile_data.new()
	var has_neighbors = find_linked_tiles(coords,check_claim_captatal(claim),claim)
	tested_tiles = []
	tile.coords = coords
	var picked_tile = main_grid.get_cell_tile_data(coords)
	if test_suroundings:
		tile.move_to_value = search_surounding_tiles(coords,dist,claim)
		if not picked_tile == null:
			if picked_tile.get_custom_data("ownership") != claim and check_tile_claimably(coords,claim):
				tile.move_to_value *= 2
			if picked_tile.get_custom_data("ownership") != claim and picked_tile.get_custom_data("type") == 3:
				tile.move_to_value *= 2
	if picked_tile == null:
		# DATA
		tile.type = -1
		tile_info.emit(tile)
		# RESULT
		return false
	elif picked_tile.get_custom_data("ownership") == claim:
		# DATA
		tile.type = 2
		tile.opposite_claim = game.claims[claim-1].name
		var neighbors = main_grid.get_surrounding_cells(coords)
		if picked_tile.get_custom_data("type") == 1:
			tile.tile_type = "capital"
			tile.points += 1
		elif picked_tile.get_custom_data("type") == 3:
			tile.tile_type = "fuel"
			tile.points -= 2
		for neighbor in neighbors:
			picked_tile = main_grid.get_cell_tile_data(neighbor)
			if not picked_tile == null:
				if picked_tile.get_custom_data("ownership") == claim:
					if picked_tile.get_custom_data("type") == 0:
						tile.points += 1
					elif picked_tile.get_custom_data("type") == 1:
						tile.points += 1
					elif picked_tile.get_custom_data("type") == 3:
						tile.points -= 1
		tile.fuel = mini(4,(check_claim_fuel_tile_count(claim)))
		tile_info.emit(tile)
		# RESULT
		return false
	elif picked_tile.get_custom_data("ownership") != 0:
		var oppose_claim = picked_tile.get_custom_data("ownership")
		tile.type = 1
		tile.opposite_claim = game.claims[oppose_claim-1].name
		# Positive and you can claim, else its unclaimable.
		var count = 1
		
		var neighbors = main_grid.get_surrounding_cells(coords)
		if picked_tile.get_custom_data("type") == 1:
			tile.opposite_claim += "'s capital"
			tile.oppose_points += 1
			count -= 1
		elif picked_tile.get_custom_data("type") == 3:
			tile.oppose_points -= 2
			count += 2
		for neighbor in neighbors:
			picked_tile = main_grid.get_cell_tile_data(neighbor)
			if not picked_tile == null:
				if picked_tile.get_custom_data("ownership") == claim:
					tile.points += 1
					count += 1
					if picked_tile.get_custom_data("type") == 1:
						tile.points += 2
						count += 2
					elif picked_tile.get_custom_data("type") == 3:
						tile.points += 1
						count += 1
				elif picked_tile.get_custom_data("ownership") == oppose_claim:
					if picked_tile.get_custom_data("type") == 0:
						tile.oppose_points += 1
						count -= 1
					elif picked_tile.get_custom_data("type") == 1:
						tile.oppose_points += 1
						count -= 1
					elif picked_tile.get_custom_data("type") == 3:
						tile.oppose_points -= 1
						count += 1
		@warning_ignore("integer_division")
		tile.fuel = mini(4,(check_claim_fuel_tile_count(claim)/2))
		tile.oppose_fuel = mini(4,(check_claim_fuel_tile_count(oppose_claim)))
		@warning_ignore("integer_division")
		count += mini(4,(check_claim_fuel_tile_count(claim)/2)) - mini(4,(check_claim_fuel_tile_count(oppose_claim)))
		if count >= 0 and has_neighbors:
			tile.available = true
			tile_info.emit(tile)
			return true
		else:
			tile_info.emit(tile)
			return false
	elif main_grid.get_cell_atlas_coords(coords) == Vector2i(0,1):
		tile.type = 3
		tile_info.emit(tile)
		return false
	else:
		if picked_tile.get_custom_data("type") == 3:
			tile.tile_type = "fuel"
		var neighbors = main_grid.get_surrounding_cells(coords)
		if has_neighbors:
			for neighbor in neighbors:
				picked_tile = main_grid.get_cell_tile_data(neighbor)
				if not picked_tile == null:
					if picked_tile.get_custom_data("ownership") == claim:
						tile.available = true
						tile_info.emit(tile)
						return true
		tile_info.emit(tile)
		return false

## Purely for spawning stuff in.
func check_tile_neutralty(coords:Vector2i,ignore_2nd_neighbor=false,ignore_neighbor=false) -> bool:
	var picked_tile = main_grid.get_cell_tile_data(coords)
	if picked_tile == null:
		return false
	elif picked_tile.get_custom_data("ownership") == 0:
		var neighbors = main_grid.get_surrounding_cells(coords)
		for neighbor in neighbors:
			picked_tile = main_grid.get_cell_tile_data(neighbor)
			if not picked_tile == null and not ignore_neighbor:
				if picked_tile.get_custom_data("ownership") != 0 or (ignore_2nd_neighbor and picked_tile.get_custom_data("type") == 3):
					return false
				# Horrorfying, I know.
				else:
					var neighbors2 = main_grid.get_surrounding_cells(neighbor)
					for neighbor2 in neighbors2:
						picked_tile = main_grid.get_cell_tile_data(neighbor2)
						if not picked_tile == null and not ignore_2nd_neighbor:
							if picked_tile.get_custom_data("ownership") != 0:
								return false
							else:
								var neighbors3 = main_grid.get_surrounding_cells(neighbor2)
								for neighbor3 in neighbors3:
									picked_tile = main_grid.get_cell_tile_data(neighbor3)
									if not picked_tile == null:
										if picked_tile.get_custom_data("ownership") != 0:
											return false
			elif not ignore_neighbor:
				return false
		return true
	else:
		return false

const dist = 3

func get_all_avalable_tiles(claim) -> Array[tile_data]:
	var claimed_tiles : Array[tile_data]
	var colection = main_grid.get_used_cells()
	for tile in colection:
		if check_tile_claimably(tile,claim):
			var new_tile = tile_data.new()
			new_tile.coords = tile
			var picked_tile = main_grid.get_cell_tile_data(tile)
			if not (picked_tile.get_custom_data("ownership") == 0 and picked_tile.get_custom_data("type") == 1):
				new_tile.move_to_value = search_surounding_tiles(tile,dist,claim)
				if not picked_tile.get_custom_data("ownership") in [0,claim] and check_tile_claimably(tile,claim):
					new_tile.move_to_value *= 2
				if picked_tile.get_custom_data("ownership") != claim and picked_tile.get_custom_data("type") == 3:
					new_tile.move_to_value *= 2
			claimed_tiles.append(new_tile)
	return claimed_tiles

func search_surounding_tiles(tile:Vector2i,distance:int,claim) -> int:
	var score = 0
	var neighbors = main_grid.get_surrounding_cells(tile)
	if distance > 0:
		for neighbor in neighbors:
			var picked_tile = main_grid.get_cell_tile_data(neighbor)
			if not picked_tile == null:
				if not (picked_tile.get_custom_data("ownership") == 0 and picked_tile.get_custom_data("type") == 1):
					if not picked_tile.get_custom_data("ownership") in [0,claim] and check_tile_claimably(tile,claim):
						score += distance
					if picked_tile.get_custom_data("ownership") != claim and picked_tile.get_custom_data("type") == 3:
						score += distance #* 2
					score += search_surounding_tiles(neighbor,distance-1,claim)
	return score

var tested_tiles = []
func find_linked_tiles(tile:Vector2i,other:Vector2i,claim) -> bool:
	var neighbors = main_grid.get_surrounding_cells(tile)
	if not tile in tested_tiles:
		tested_tiles.append(tile)
		for neighbor in neighbors:
			var picked_tile = main_grid.get_cell_tile_data(neighbor)
			if not picked_tile == null and not neighbor in tested_tiles:
				if picked_tile.get_custom_data("ownership") == claim:
					if neighbor == other:
						return true
					elif find_linked_tiles(neighbor,other,claim):
						return true
	return false

## Checks the amount of tiles a claim has.
func check_claim_tile_count(claim) -> int:
	var count = 0
	var colection = main_grid.get_used_cells()
	for tile in colection:
		var picked_tile = main_grid.get_cell_tile_data(tile)
		if not picked_tile == null:
			if picked_tile.get_custom_data("ownership") == claim:
				count += 1
	return count

func check_claim_fuel_tile_count(claim) -> int:
	var count = 0
	var colection = main_grid.get_used_cells()
	for tile in colection:
		var picked_tile = main_grid.get_cell_tile_data(tile)
		if not picked_tile == null:
			if picked_tile.get_custom_data("ownership") == claim and picked_tile.get_custom_data("type") == 3:
				#if find_linked_tiles(tile,check_claim_captatal(claim),claim):
				count += 1
	tested_tiles = []
	return count

func check_claim_tile_type_count(claim,type) -> int:
	var count = 0
	var colection = main_grid.get_used_cells()
	for tile in colection:
		var picked_tile = main_grid.get_cell_tile_data(tile)
		if not picked_tile == null:
			if picked_tile.get_custom_data("ownership") == claim and picked_tile.get_custom_data("type") == type:
				#if find_linked_tiles(tile,check_claim_captatal(claim),claim):
				count += 1
	tested_tiles = []
	return count

func check_claim_captatal(claim) -> Vector2i:
	var coord = Vector2i(9999999,9999999)
	var colection = main_grid.get_used_cells()
	for tile in colection:
		var picked_tile = main_grid.get_cell_tile_data(tile)
		if not picked_tile == null:
			if picked_tile.get_custom_data("ownership") == claim and picked_tile.get_custom_data("type") == 1:
				coord = tile
	return coord
