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

## The main grid. 18x20 or a 3 to 4 ratio
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

## Used just for paterns.
var tile_set : TileSet

## For game sounds. (CURRENTLY USING SOUNDS FROM GOD MACHINE)
var sound : AudioStreamPlayer

var lot : Vector4i

func _ready():
	
	enabled_claims.clear()
	#mp If I were to make it so I would take into acount that Global.[claim]_enabled is the 0, 1, 2 option system.
	#mp I'd first have to make it so the game can see if the part is more than 0, the claim is enabled.
	#mp This wouldn't likely afect the genration, however this isn't the only place were I would need to respesfiy.
	#mp Both the Game script, and claim data panels would have to:
		#mp 1: 	be able to set them selves to which is enabled. Npc or Pc
		#mp 2: 	give each player a diffrent name for each player.
		#mp 3: 	make it so the game as a hole can cycle through each active player.
			#mp 3.1:  	Also I might have to make so when there are no players, so I can seemlessly go through a turn,
			#mp   		and still give the player to contine to the next turn.
	#mp So,lets not be hasty, and break a bunch of shit like last time with the GENRATION.
	#mp AND COMMENT WHAT I THINK IT SHOULD LOOK LIKE.
	#mp so if you see a tag after the "#" that looks like this: "mp"
	#mp That relates to this.
	enabled_claims.append_array([
		true if Global.claim_list[0] > 0 else false,
		true if Global.claim_list[1] > 0 else false,
		true if Global.claim_list[2] > 0 else false,
		true if Global.claim_list[3] > 0 else false]
		)
	sound = AudioStreamPlayer.new()
	add_child(sound)
	sound.volume_db = linear_to_db(Global.SFX_vol/10)
	
	var set_of_grid : Array[Vector2i] = main_grid.get_used_cells()
	var maxx = set_of_grid.max()
	var minn = set_of_grid.min()
	lot = Vector4i(maxx.x,maxx.y,minn.x,minn.y)
	print(lot)
	
	# Set map
	tile_set = main_grid.tile_set
	var placement = Vector2i(-10,-13)
	if Global.map_type == 1:
		placement.x = -10
	main_grid.set_pattern(placement,tile_set.get_pattern(Global.map_type))
	
	var break_loop = 500
	var end_genration = 3
	# Genration
	var rcoord : Callable = func(dot=false,wall=false,tries=-999):
		var thing
		var spot = false
		while not spot and tries != 0:
			thing = Vector2i(randi_range(lot.z,lot.x),randi_range(lot.w,lot.y))
			spot = check_tile_neutralty(thing,dot,wall)
			tries -= 1
			if tries == 0:
				#print("Error: could not find a place for a tile, placing in null location. Dont have such high gen settings.")
				thing = null
				#OS.alert("Error: could not find a place for a tile, Dont have such high gen settings.", "ERROR.001")
				#OS.crash("ERROR")
				#var test = null
				#test.kill() # This will crash the game
		return thing
	
	# Places all enabled players.
	for i in range(0,4):
		if enabled_claims[i] and check_claim_captatal(i+1).size() < Global.cap_list[i]:
			for x in range(check_claim_tile_type_count(i+1,1),Global.cap_list[i]):
				if not on_claim_tile(rcoord.call(false,false,break_loop),i+1,1,false):
					print_rich("[color=red][b]GEN_ERROR.001:[/b] could not find a place for a captial, Dont have such high gen settings.[/color]")
					OS.alert("Error: could not find a place for a capital tile, Dont have such high gen settings. The game will break after this, ENDING GAME", "GEN_ERROR.001")
					OS.crash("ERROR")
					var test = null
					test.kill() # This will crash the game
		elif enabled_claims[i] and check_claim_captatal(i+1).size() > Global.cap_list[i]:
			while check_claim_captatal(i+1).size() > Global.cap_list[i]:
				on_claim_tile(check_claim_captatal(i+1).pick_random(),0,2,false)
		elif not enabled_claims[i]:
			for x in check_claim_captatal(i+1):
				on_claim_tile(x,0,2,false)
		print(i+1," capitals: ",check_claim_captatal(i+1).size())
	
	# This places down all the unowned tile, and will not stop untill it gets the right amount.
	while ( check_claim_tile_type_count(0,1) < Global.wall_count
			or
			check_claim_tile_type_count(-1,3) < Global.fuel_count):
		
		if check_claim_tile_type_count(0,1) < Global.wall_count:
			if not on_claim_tile(rcoord.call(false,true,break_loop),0,1,false,true):
				end_genration -= 1
				print_rich("[color=red][b]GEN_ERROR.002:[/b] could not find a place for a wall tile, Dont have such high gen settings.[/color]")
				OS.alert("Error: could not find a place for a wall tile, Dont have such high gen settings.", "GEN_ERROR.002")
				#OS.crash("ERROR")
				#var test = null
				#test.kill() # This will crash the game
		
		if check_claim_tile_type_count(-1,3) < Global.fuel_count:
			if not on_claim_tile(rcoord.call(true,false,break_loop),0,3,false,true):
				end_genration -= 1
				print_rich("[color=red][b]GEN_ERROR.003:[/b] could not find a place for a tile, Dont have such high gen settings.[/color]")
				OS.alert("Error: could not find a place for a fuel tile, Dont have such high gen settings.", "GEN_ERROR.003")
				#OS.crash("ERROR")
				#var test = null
				#test.kill() # This will crash the game
		
		if end_genration == 0:
			print("Stopping.")
			break
			#OS.alert("Error: could not find a place for a tile, Dont have such high gen settings.", "ERROR.003")
			#OS.crash("ERROR")
			#var test = null
			#test.kill() # This will crash the game
		
	# Debug test if the walls and fuel
	print("wall: ",check_claim_tile_type_count(0,1))
	print("fuel: ",check_claim_tile_type_count(-1,3))
	for i in check_special_empty_tiles():
		on_claim_tile(i,0,0,false,true)


func _process(_delta):
	if hovered:
		# Get mouse position on grid.
		var mouse_pos = get_global_mouse_position()
		overlay_grid.clear()
		grid_coords = overlay_grid.local_to_map(overlay_grid.to_local(mouse_pos))
		
		# See if tile is claimable
		lock_mode = not check_tile_claimably(grid_coords,game.active_player.claim_colour) #mp replace 1 with game.active_player.claim_colour
		
		# Set the overlay
		var type = 2 if lock_mode or off_input else 0
		if lock_mode:
			overlay_grid.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			overlay_grid.modulate = Color(0.5, 0.5, 0.5, 0.255)
		overlay_grid.set_cell(grid_coords, 0, Vector2i(game.active_player.claim_colour,type))


## Gets if the mouse enters the board. [member board.hovered]
func _on_mouse_entered():
	hovered = true

## Gets if the mouse leaves the board. [member board.hovered]
func _on_mouse_exited():
	hovered = false

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and not (lock_mode or off_input):
			on_claim_tile(grid_coords,game.active_player.claim_colour) #mp replace 1 with game.active_player.claim_colour
			sound.stream = load("res://audio/FX/left click sound.mp3") as AudioStream
			game.gui_board_events()
		elif (lock_mode or off_input):
			sound.stream = load("res://audio/FX/right click sound.mp3") as AudioStream
			game.gui_board_events()
		sound.play()

## Sets a tile on the main board.
func on_claim_tile(coords,claim:int,type:int=-1,update=true,terain=false):
	if coords is Vector2i:
		var picked_tile : TileData = main_grid.get_cell_tile_data(coords)
		if picked_tile != null:
			var changed = true
			if picked_tile.get_custom_data("type") == 1 and type == -1:
				type = 1
			elif picked_tile.get_custom_data("type") == 2 and type in [1,3]:
				type = 2
				changed = false
			elif picked_tile.get_custom_data("type") == 3 and type == -1:
				type = 3
			elif type == -1:
				type = 0
			main_grid.set_cell(coords,0,Vector2i(claim,type))
			if (picked_tile.get_custom_data("type") == 1 or (type == 1 or type == 2) and not picked_tile.get_custom_data("type") == 1) and not terain:
				if type != 2:
					type = 0
				var neighbors = main_grid.get_surrounding_cells(coords)
				for neighbor in neighbors:
					picked_tile = main_grid.get_cell_tile_data(neighbor)
					if not picked_tile == null:
						on_claim_tile(neighbor,claim,type,false,true)
			if update:
				game_state_change.emit()
			return changed
		#else:
			#print("Failed to place a tile as the coords given: {0}, are outside map boundrys".format([coords]))
	#else:
		#print("Failed to place a tile as wasn't spesifed a coord")
	return false

## Checks if a tile can be claimed. Returns true if claimable.
func check_tile_claimably(coords:Vector2i,claim:int,test_suroundings=false) -> bool:
	var tile = tile_data.new()
	var has_neighbors = find_linked_tiles(coords,check_claim_captatal(claim),claim)
	tested_tiles = []
	tile.coords = coords
	var picked_tile = main_grid.get_cell_tile_data(coords)
	if test_suroundings:
		#tile.move_to_value = search_surounding_tiles(coords,Global.dist,claim)
		#if not picked_tile == null:
			#if picked_tile.get_custom_data("ownership") != claim and check_tile_claimably(coords,claim):
				#tile.move_to_value *= 2
			#if picked_tile.get_custom_data("ownership") != claim and picked_tile.get_custom_data("type") == 3:
				#tile.move_to_value *= 2
		tile = start_search(tile,coords,claim)
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
		
		# The most messest ways to write this, it work though.
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
		var cap_buff = 0
		var caps_linked : Array[Vector2i]
		for neighbor in neighbors:
			picked_tile = main_grid.get_cell_tile_data(neighbor)
			if not picked_tile == null:
				# if this is one of the player claims.
				if picked_tile.get_custom_data("ownership") == claim:
					tile.points += 1
					count += 1
					# Tracks how meny capitals
					for x in check_claim_captatal(claim).filter(func(_coords): return not _coords in caps_linked):
						tested_tiles = []
						if find_linked_tiles(tile.coords,[x],claim,18):
							caps_linked.append(x)
							tile.cap_list.append(x)
							cap_buff += 1
					if picked_tile.get_custom_data("type") == 1:
						tile.points += 2
						count += 2
					elif picked_tile.get_custom_data("type") == 3:
						tile.points += 1
						count += 1
				# elif this it one of the opposing claims
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
		picked_tile = main_grid.get_cell_tile_data(coords)
		if picked_tile.get_custom_data("type") != 1:
			tested_tiles = []
			# If your tiles are connected to 2 capitals or more, you get a +2 boost when attacking.
			if cap_buff >= 1:
				#tile.points += cap_buff
				count += cap_buff
			cap_buff = 0
			for x in check_claim_captatal(oppose_claim):
				cap_buff += 1 if find_linked_tiles(tile.coords,[x],oppose_claim) else 0
				#print(cap_buff)
			# If the tile isn't conected to a capital, then it gets a -10 debuff to reward cutting off areas.
			if cap_buff == 0:
				tile.oppose_points -= 10
				count += 10
			#elif cap_buff >= 2:
				#tile.oppose_points += 1
				#count += 1
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
		# check if it is a fuel tile
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
	elif picked_tile.get_custom_data("ownership") == 0 and not picked_tile.get_custom_data("type") in [1,2,3]:
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

## Gets all avaliable tile around a claim.
func get_all_avalable_tiles(claim,ignore_set:Array[Vector2i]=[]) -> Array[tile_data]:
	var claimed_tiles : Array[tile_data]
	# gets the hole grid.
	var colection = main_grid.get_used_cells()
	# the loop that looks arround
	for tile in colection:
		if not tile in ignore_set:
			if check_tile_claimably(tile,claim):
				var new_tile = tile_data.new()
				new_tile.coords = tile
				
				#var picked_tile = main_grid.get_cell_tile_data(tile)
				#if not (picked_tile.get_custom_data("ownership") == 0 and picked_tile.get_custom_data("type") == 1):
					#new_tile.move_to_value = search_surounding_tiles(tile,Global.dist,claim)
					#if not picked_tile.get_custom_data("ownership") in [0,claim] and check_tile_claimably(tile,claim):
						#new_tile.move_to_value *= 2
					#if picked_tile.get_custom_data("ownership") != claim and picked_tile.get_custom_data("type") == 3:
						#new_tile.move_to_value *= 2
				# this is what is above, but as a seprate func
				new_tile = start_search(new_tile,tile,claim,ignore_set,60.0)
				claimed_tiles.append(new_tile)
	broke_timer = false
	return claimed_tiles

## Gets all avaliable tiles around a tile. See [method board.get_all_avalable_tiles] for more info.
func get_all_local_avalable_tiles(coords,claim,ignore_set:Array[Vector2i]=[]) -> Array[tile_data]:
	
	var claimed_tiles : Array[tile_data]
	var neighbors = main_grid.get_surrounding_cells(coords)
	for neighbor in neighbors:
		if not neighbor in ignore_set:
			if check_tile_claimably(neighbor,claim):
				var new_tile = tile_data.new()
				new_tile.coords = neighbor
				#var picked_tile = main_grid.get_cell_tile_data(coords)
				#if not (picked_tile.get_custom_data("ownership") == 0 and picked_tile.get_custom_data("type") == 1):
					#new_tile.move_to_value = search_surounding_tiles(coords,Global.dist,claim)
					#if not picked_tile.get_custom_data("ownership") in [0,claim] and check_tile_claimably(coords,claim):
						#new_tile.move_to_value = 1 if new_tile.move_to_value <= 0 else new_tile.move_to_value 
						#new_tile.move_to_value *= 2
					#if picked_tile.get_custom_data("ownership") != claim and picked_tile.get_custom_data("type") == 3:
						#new_tile.move_to_value = 1 if new_tile.move_to_value <= 0 else new_tile.move_to_value 
						#new_tile.move_to_value *= 2
				# this is what is above, but as a seprate func
				new_tile = start_search(new_tile,neighbor,claim,ignore_set,120.0)
				claimed_tiles.append(new_tile)
	broke_timer = false
	return claimed_tiles

func start_search(new_tile:tile_data,coords:Vector2i,claim:int,ignore_set:Array[Vector2i]=[],stop_time=-1.0) -> tile_data:
	# The ai personaltys
	var ai_data : ClaimData = game.claims[claim-1] if claim > 0 else game.claims[claim]
	var can_use_ai = true if Global.ai_level >= 1 else false
	if not ai_data is NonPlayerClaim and can_use_ai:
		can_use_ai = false
	#elif can_use_ai:
		#can_use_ai = true
	
	var picked_tile = main_grid.get_cell_tile_data(coords)
	if not picked_tile == null:
		if not (picked_tile.get_custom_data("ownership") == 0 and picked_tile.get_custom_data("type") == 1):
			
			new_tile.move_to_value = search_surounding_tiles(coords,Global.dist,claim,
															ignore_set,
															can_use_ai,ai_data,
															float(Time.get_ticks_usec())/1000,stop_time)
			
			if picked_tile.get_custom_data("ownership") != claim and picked_tile.get_custom_data("type") == 3:
				new_tile.move_to_value = 1 if new_tile.move_to_value <= 0 else new_tile.move_to_value 
				new_tile.move_to_value *= ai_data.fuel_beeline if can_use_ai else 1
			
			if not picked_tile.get_custom_data("ownership") in [0,claim] and check_tile_claimably(coords,claim):
				new_tile.move_to_value = 1 if new_tile.move_to_value <= 0 else new_tile.move_to_value 
				new_tile.move_to_value *= ai_data.stratigic_beeline if can_use_ai else 1
			
			if not picked_tile.get_custom_data("ownership") in [0,claim] and picked_tile.get_custom_data("type") == 1:
				new_tile.move_to_value = 1 if new_tile.move_to_value <= 0 else new_tile.move_to_value 
				new_tile.move_to_value *= ai_data.capital_beeline if can_use_ai else 1
	#if can_use_ai:
		#print("This tile has the folowing info\n--------------")
		#print(new_tile.get_info()+"\n------------")
	return new_tile


# Fill oprations.
## Makes sheure that [s]these two[/s] this method does not repeat itself:[br]
## [method board.find_linked_tiles][br]
## [s][method board.search_surounding_tiles][/s]
var tested_tiles = []
var broke_timer = false
## Searches the surounding tiles to give is tile a score for how much that it is worthed.
func search_surounding_tiles(tile:Vector2i,distance:int,claim,ignore_set:Array[Vector2i]=[],can_use_ai:bool=false,ai_data:ClaimData=ClaimData.new(),start_time=float(Time.get_ticks_usec())/1000,time_limit_s=-1.0,burnup=0.1) -> int:
	var score = 0
	var neighbors = main_grid.get_surrounding_cells(tile)
	if not tile in ignore_set:
		#tested_tiles.append(tile)
		# It times the search so if it is taking too long, than it will be broken.
		var time_cur = (float(Time.get_ticks_usec())/1000 - start_time)
		if distance > 0 and time_cur < time_limit_s:# and not broke_timer:
			for neighbor in neighbors:
				var picked_tile = main_grid.get_cell_tile_data(neighbor)
				if not picked_tile == null:
					#if not (picked_tile.get_custom_data("ownership") == 0 and picked_tile.get_custom_data("type") == 1): #check_tile_claimably(tile,claim)
					# If this is a fuel source, then the ai will go for it.
					var fuel_weight = picked_tile.get_custom_data("ownership") != claim and picked_tile.get_custom_data("type") == 3
					if fuel_weight:
						score += distance * ai_data.fuel_beeline if can_use_ai else distance
					# This looks if the tile is of a enemy, and that they can take it.
					var stratigic_weight = not picked_tile.get_custom_data("ownership") in [0,claim] and check_tile_claimably(tile,claim)
					if stratigic_weight:
						score += distance * ai_data.stratigic_beeline if can_use_ai else distance
					# This looks if the tile is of a enemy, regadless of if they can take it or not.
					var blindless_weight = not picked_tile.get_custom_data("ownership") in [0,claim]
					if blindless_weight:
						score += distance * ai_data.blindless_beeline if can_use_ai else distance * 0
					
					var teratory_weight = picked_tile.get_custom_data("ownership") == claim 
					if teratory_weight:
						score += maxi(distance - (Global.dist - 1),0) * ai_data.teratory_beeline if can_use_ai else maxi(distance - (Global.dist - 1),0) * 0
					
					var capital_weight = not picked_tile.get_custom_data("ownership") in [0,claim] and picked_tile.get_custom_data("type") == 1 and check_tile_claimably(tile,claim)
					if capital_weight:
						score += maxi(distance - (Global.dist - 1),0) * ai_data.capital_beeline if can_use_ai else maxi(distance - (Global.dist - 1),0) * 0
					
					var wall_weight = picked_tile.get_custom_data("ownership") == 0 and picked_tile.get_custom_data("type") == 1
					if wall_weight:
						score += distance * ai_data.wall_beeline if can_use_ai else distance * 0
					
					# Maybe seeing if it has hit something it will stop looking around and just go back. Maybe.
					# I have no Idea though. :\
					if not (fuel_weight and stratigic_weight and blindless_weight and teratory_weight and capital_weight and wall_weight):
						score += search_surounding_tiles(neighbor,distance-1,claim,[],can_use_ai,ai_data,start_time,time_limit_s-burnup)
		elif time_cur >= time_limit_s and time_limit_s >= 0 and not broke_timer: 
			print("timer broke. :( \nTime was: ",time_cur)
			broke_timer = true
	return score

## Finds if two points are linked, normaly one tile, and its capital.
func find_linked_tiles(tile:Vector2i,other:Array[Vector2i],claim,limit=-1) -> bool:
	var answer = false
	var neighbors = main_grid.get_surrounding_cells(tile)
	if not tile in tested_tiles and limit != 0:
		tested_tiles.append(tile)
		for neighbor in neighbors:
			var picked_tile = main_grid.get_cell_tile_data(neighbor)
			if not picked_tile == null and not neighbor in tested_tiles:
				if picked_tile.get_custom_data("ownership") == claim:
					if neighbor in other:
						return true
					elif find_linked_tiles(neighbor,other,claim,limit-1):
						answer = true
			if not neighbor in tested_tiles:
				tested_tiles.append(neighbor)
	return answer


# count oprations

## Checks the amount of tiles a claim has. See [method board.find_linked_tiles] for more info
func check_claim_tile_count(claim) -> int:
	#var count = 0
	#for i in [0,1,3]:
		#count += check_claim_tile_type_count(claim,i)
	# ORIGNAL CODE
	var count = 0
	var colection = main_grid.get_used_cells()
	for tile in colection:
		var picked_tile = main_grid.get_cell_tile_data(tile)
		if not picked_tile == null:
			if picked_tile.get_custom_data("ownership") == claim:
				count += 1
	return count

## Just returns the number of fuel own by a claim. See [method board.find_linked_tiles] for more info
func check_claim_fuel_tile_count(claim) -> int:
	var count = 0
	var colection = main_grid.get_used_cells()
	for tile in colection:
		var picked_tile = main_grid.get_cell_tile_data(tile)
		if not picked_tile == null:
			if picked_tile.get_custom_data("ownership") == claim and picked_tile.get_custom_data("type") == 3:
				# I want it so, if this tile isn't linked to the capital, then its not counted
				if claim != 0:
					if find_linked_tiles(tile,check_claim_captatal(claim),claim):
						tested_tiles = []
						count += 1
				else:
					count += 1
	tested_tiles = []
	return count

## Gets all of a one tile type, from its claim and its accual type.[br]
## [code]claim[/code] is asking which claim do we need to look at. If it is -1, it won't care what type it is. [br]
## [code]type[/code] what type of tile is it.[br][code]Plain[/code]=0,[br][code]Wall/capital[/code]=1,[br][code]refuse hover[/code]=2,[br][code]fuel[/code]=3.[br][br][br]
##Heres an example of how to use this function.[codeblock]
## var i = check_claim_tile_type_count(0,1)
## print(i) # prints the number of walls on the map.
##[/codeblock]
func check_claim_tile_type_count(claim,type) -> int:
	var count = 0
	var colection = main_grid.get_used_cells()
	for tile in colection:
		var picked_tile = main_grid.get_cell_tile_data(tile)
		if not picked_tile == null:
			if (picked_tile.get_custom_data("ownership") == claim or claim == -1) and picked_tile.get_custom_data("type") == type:
				# I want it so, if this tile isn't linked to the capital, then its not counted
				if claim > 0:
					if find_linked_tiles(tile,check_claim_captatal(claim),claim):
						tested_tiles = []
						count += 1
				else:
					count += 1
	tested_tiles = []
	return count


# coords

## Gets the positon of the preplaced empty tile, to make acualy empty.
func check_special_empty_tiles() -> Array[Vector2i]:
	var coord : Array[Vector2i]
	var colection = main_grid.get_used_cells()
	for tile in colection:
		var picked_tile = main_grid.get_cell_tile_data(tile)
		if not picked_tile == null:
			if picked_tile.get_custom_data("ownership") == 0 and picked_tile.get_custom_data("type") == 2:
				coord.append(tile)
	return coord


## Gets the positon of the capitals.
func check_claim_captatal(claim:int) -> Array[Vector2i]:
	var coord : Array[Vector2i]
	var colection = main_grid.get_used_cells()
	for tile in colection:
		var picked_tile = main_grid.get_cell_tile_data(tile)
		if not picked_tile == null:
			if picked_tile.get_custom_data("ownership") == claim and picked_tile.get_custom_data("type") == 1:
				coord.append(tile)
	return coord
