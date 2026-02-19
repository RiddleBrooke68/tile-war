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

@export var click_efect : PackedScene

## The main grid. 18x20 or a 3 to 4 ratio
@onready var main_grid : TileMapLayer = $main_grid
## The overlay thats to show the player what their clicking.
@onready var overlay_grid : TileMapLayer = $overlay_grid

@onready var action_grid : TileMapLayer = $action_grid

const placement = Vector2i(-10,-13)

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
	#mp I would probably need to get the set for who are players, who are bots, we don't realy need to know if their disabled or not, as their capitals won't spawn.
	#mp And set them up with the [code]claims[/code]
	#mp So cross refrence from Global.claim_list
	#colour Just setting it up.
	for i in range(Global.claim_colours.size()):
		if Global.claim_list[i] == 2:
			game.claims[i] = game.claim_lookup.pc_claim_data[Global.claim_colours[i]-1]
			game.claims[i].name = Global.claim_names[i] if Global.claim_names[i] != "" or Global.claim_names.filter(func(_names): return _names == Global.claim_names[i]).size() <= 1 else game.claims[i].name
			if Global.mp_enabled:
				for x in Global.mp_player_list.keys():
					if i == Global.mp_player_list[x].current_claim - 1:
						game.claims[i].name = Global.mp_player_list[x].name
						game.claims[i].claim_mp_ip_linked = x
		else:
			game.claims[i] = game.claim_lookup.npc_claim_data[Global.claim_colours[i]-1]
		game.claims[i].claim_turn_slot = i
		game.panels[i].claim = game.claims[i]
	for i in game.claims:
		game.claims_order[i.claim_colour-1] = game.claims[i.claim_turn_slot]
	
	sound = AudioStreamPlayer.new()
	add_child(sound)
	sound.volume_db = linear_to_db(Global.SFX_vol/10)
	
	
	
	# Read map limits
	var set_of_grid : Array[Vector2i] = main_grid.get_used_cells()
	var maxx = set_of_grid.max()
	var minn = set_of_grid.min()
	lot = Vector4i(maxx.x,maxx.y,minn.x,minn.y)
	print(lot)
	
	if not Global.mp_enabled or Global.mp_host:
		# Pre Gen
		tile_set = main_grid.tile_set
		#var placement = Vector2i(-10,-13)
		#if Global.map_type == 1:
			#placement.x = -10
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
					if not on_claim_tile(rcoord.call(false,false,break_loop),i+1,1,false,false,true):
						print_rich("[color=red][b]GEN_ERROR.001:[/b] could not find a place for a captial, Dont have such high gen settings.[/color]")
						OS.alert("Error: could not find a place for a capital tile, Dont have such high gen settings. The game will break after this, ENDING GAME", "GEN_ERROR.001")
						OS.crash("ERROR")
						var test = null
						test.kill() # This will crash the game
			elif enabled_claims[i] and check_claim_captatal(i+1).size() > Global.cap_list[i]:
				while check_claim_captatal(i+1).size() > Global.cap_list[i]:
					on_claim_tile(check_claim_captatal(i+1).pick_random(),0,2,false,false,true)
			elif not enabled_claims[i]:
				for x in check_claim_captatal(i+1):
					on_claim_tile(x,0,2,false,false,true)
			
			if enabled_claims[i] and check_claim_captatal(i+1).size() == Global.cap_list[i]:
				for x in check_claim_captatal(i+1):
					on_claim_tile(x,game.claims[i],1,false,false,true)
			print(i+1," capitals: ",check_claim_captatal(i+1).size())
		
		# This places down all the unowned tile, and will not stop untill it gets the right amount.
		while ( check_claim_tile_type_count(0,1) < Global.wall_count
				or
				check_claim_tile_type_count(-1,3) < Global.fuel_count):
			
			if check_claim_tile_type_count(0,1) < Global.wall_count:
				if not on_claim_tile(rcoord.call(false,true,break_loop),0,1,false,true,true):
					end_genration -= 1
					print_rich("[color=red][b]GEN_ERROR.002:[/b] could not find a place for a wall tile, Dont have such high gen settings.[/color]")
					OS.alert("Error: could not find a place for a wall tile, Dont have such high gen settings.", "GEN_ERROR.002")
					#OS.crash("ERROR")
					#var test = null
					#test.kill() # This will crash the game
			
			if check_claim_tile_type_count(-1,3) < Global.fuel_count:
				if not on_claim_tile(rcoord.call(true,false,break_loop),0,3,false,true,true):
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
			on_claim_tile(i,0,0,false,true,true)
		
		if Global.mp_enabled:
			mp_update_board_state.rpc(serialize_pattern(main_grid.get_pattern(set_of_grid)))


func _process(_delta):
	if hovered:
		# Get mouse position on grid.
		var mouse_pos = get_global_mouse_position()
		overlay_grid.clear()
		grid_coords = overlay_grid.local_to_map(overlay_grid.to_local(mouse_pos))
		
		# See if tile is claimable
		lock_mode = not check_tile_claimably(grid_coords,game.active_player) #mp replace 1 with game.active_player.claim_colour
		
		# Set the overlay
		var type = 2 if lock_mode or off_input else 0
		if lock_mode:
			overlay_grid.modulate = Color(1.0, 1.0, 1.0, 0.627)
		else:
			overlay_grid.modulate = Color(0.5, 0.5, 0.5, 0.255)
		overlay_grid.set_cell(grid_coords, 0, Vector2i(game.active_player.claim_colour,type))
	
	else:
		overlay_grid.clear()


func serialize_pattern(pattern: TileMapPattern) -> Dictionary:
	var pattern_data := {}
	pattern_data["size"] = pattern.get_size() # Get the size of the pattern
	var cells_data := []
	
	# Iterate over all used cells in the pattern
	for coords in pattern.get_used_cells():
		var cell_data := {}
		cell_data["coords"] = coords
		cell_data["source_id"] = pattern.get_cell_source_id(coords)
		cell_data["atlas_coords"] = pattern.get_cell_atlas_coords(coords)
		cell_data["alternative_tile"] = pattern.get_cell_alternative_tile(coords)
		cells_data.append(cell_data)
	
	pattern_data["cells"] = cells_data
	return pattern_data

func deserialize_pattern(pattern_data: Dictionary) -> TileMapPattern:
	var pattern := TileMapPattern.new()
	pattern.set_size(pattern_data["size"])
	
	for cell_data in pattern_data["cells"]:
		pattern.set_cell(
		cell_data["coords"],
		cell_data["source_id"],
		cell_data["atlas_coords"],
		cell_data["alternative_tile"]
		)
	return pattern

@rpc("any_peer")
func mp_update_board_state(board_state:Dictionary):
	main_grid.set_pattern(placement,deserialize_pattern(board_state))


## Gets if the mouse enters the board. [member board.hovered]
func _on_mouse_entered():
	hovered = true

## Gets if the mouse leaves the board. [member board.hovered]
func _on_mouse_exited():
	hovered = false

const colours = {
	"Greenwich":Color(0.501, 0.801, 0.456, 0.0),
	"Plum":Color(0.614, 0.185, 0.77, 0.0),
	"York":Color(1.0, 0.936, 0.36, 0.0),
	"River":Color(0.72, 0.166, 0.166, 0.0),
	"Builders":Color(0.23, 0.487, 1.0, 0.0)
}

func click_effect_color(c:Color,coords):
	var node : Node2D = click_efect.instantiate()
	add_child(node)
	node.global_position = coords
	node.start(c)

signal board_decrese_move_count(incremts:int)

## Fires for any click on the board.
func _on_gui_input(event):
	if event is InputEventMouseButton:
		var tile : tile_data = check_tile_claimably(grid_coords,game.active_player,-1,true)
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and not (lock_mode or off_input):
			board_decrese_move_count.emit(1)
			on_claim_tile(grid_coords,game.active_player) #mp replace 1 with game.active_player.claim_colour
			sound.stream = load("res://audio/FX/left click sound.mp3") as AudioStream
			click_effect_color(game.active_player.claim_real_color,overlay_grid.to_global(overlay_grid.map_to_local(grid_coords)))
		
		elif event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed and not off_input:
			if not tile.available and on_claim_tile(grid_coords,game.active_player.claim_colour,-1,true,false,false,true): #mp replace 1 with game.active_player.claim_colour
				board_decrese_move_count.emit(Global.blz_move_requrement)
				sound.stream = load("res://audio/FX/left click sound.mp3") as AudioStream
			
			elif on_claim_tile(grid_coords,game.active_player.claim_colour):
				board_decrese_move_count.emit(1)
				sound.stream = load("res://audio/FX/left click sound.mp3") as AudioStream
			
			else:
				sound.stream = load("res://audio/FX/right click sound.mp3") as AudioStream
			
		elif (lock_mode or off_input):
			sound.stream = load("res://audio/FX/right click sound.mp3") as AudioStream
		
		tile = check_tile_claimably(grid_coords,game.active_player,-1,true)
		game.gui_board_events(tile)
		sound.play()

@rpc("any_peer")
## Fires only when there is a mpui input from other clients.
func _on_mpui_input(coords,claim:int,type:int=-1,update=true,terain=false,force_do=false,blz_fired=false,did_claim=true,mp_ran_results=[0,0]):
	if on_claim_tile(coords,claim,type,update,terain,force_do,blz_fired,false,did_claim,mp_ran_results):
		sound.stream = load("res://audio/FX/left click sound.mp3") as AudioStream
	
	else:
		sound.stream = load("res://audio/FX/right click sound.mp3") as AudioStream
	var tile : tile_data = check_tile_claimably(coords,game.active_player,-1,true)
	game.gui_board_events(tile)
	sound.play()


## Sets a tile on the main board.
func on_claim_tile(coords,claim,type:int=-1,
					update=true,terain=false,force_do=false,blz_fired=false,
					mp_player_source=true,mp_did_claim=false,mp_ran_results=[0,0]
				) -> bool:
	
	var claim_colour = claim
	var claim_slot = claim
	
	if not claim is int and claim is ClaimData:
		claim_colour = claim.claim_colour
		claim_slot = claim.claim_turn_slot
	elif not claim is int and not claim is ClaimData:
		print_rich("[color=red][b]ERROR (method 'check_tile_claimably'):[/b] Claim paramater was not a Int or a ClaimData.[/color]")
		return false
	
	if coords is Vector2i:
		var picked_tile : TileData = main_grid.get_cell_tile_data(coords)
		if picked_tile != null:
			var changed = true
			var did_claim = false
			var tile : tile_data = check_tile_claimably(coords,claim,false,true,blz_fired,true) if not (terain or force_do) else tile_data.new()
			var ran_attacker
			var ran_defender
			var mp_start_type = type
			#bran So when bran is active this has to check if its takeable or not and then will check if it needs to make a roll or not.
			if Global.bran_enabled and not force_do and check_tile_claimably(coords,claim,false,false,blz_fired,true):
				if mp_did_claim or did_claim:
					ran_attacker = mp_ran_results[0]
					ran_defender = mp_ran_results[1]
				else:
					@warning_ignore("incompatible_ternary")
					ran_attacker = randi_range(0,10)+tile.points+tile.fuel if tile.type == 1 else null
					@warning_ignore("incompatible_ternary")
					ran_defender = randi_range(0,10)+tile.oppose_points+tile.oppose_fuel if tile.type == 1 else null
					did_claim = true
				if tile.type == 1 and ran_attacker < ran_defender:
					print("Fail, {0}, {1}".format([ran_attacker,ran_defender]))
					game.failed_move = true
					changed = false
			if (not tile.available or (Global.blz_enabled and blz_fired and game.claims[claim_slot].moves < Global.blz_move_requrement)) and not force_do:
				changed = false
			#elif Global.bran_enabled and not check_tile_claimably(coords,claim):
				#changed = false
			if changed:
				if picked_tile.get_custom_data("type") == 1 and type == -1:
					if Global.cdan_enabled and picked_tile.get_custom_data("ownership") != 0:
						tile.opposite_claim_data.claim_dangered = 5 * (Global.cdan_duration+1)
						if claim == game.active_player.claim_colour:
							game.active_player.orginal_claim.claim_dangered = 5 * (Global.cdan_capture_duration+1)
					type = 1
				elif picked_tile.get_custom_data("type") == 2 and type in [1,3]:
					type = 2
					changed = false
				elif picked_tile.get_custom_data("type") == 3 and type == -1:
					type = 3
				elif type == -1:
					type = 0
				main_grid.set_cell(coords,0,Vector2i(claim_colour,type))
				if (picked_tile.get_custom_data("type") == 1 or (type == 1 or type == 2) and not picked_tile.get_custom_data("type") == 1) and changed and not terain:
					if type != 2:
						type = 0
					var neighbors = main_grid.get_surrounding_cells(coords)
					for neighbor in neighbors:
						picked_tile = main_grid.get_cell_tile_data(neighbor)
						if not picked_tile == null:
							on_claim_tile(neighbor,claim,type,false,true,true)
							if not force_do:
								var ntile : tile_data = check_tile_claimably(neighbor,claim,-1,true)
								game.gui_board_events(ntile)
			if update:
				game_state_change.emit()
			if not terain and not force_do:
				var bliz_state = "bliz" if Global.blz_enabled and blz_fired else "take"
				var roll = "\nWith a roll of: {0}Atk aganst {1}Def".format([ran_attacker,ran_defender]) if ran_attacker != null and ran_defender != null else ""
				var result = (
						"{0} was able to {3} this tile at: {1}{2}".format([
							game.active_player.name,
							coords,
							roll,
							bliz_state])
						if changed else 
						"{0} wasnt able to {3} this tile at: {1}{2}".format([
							game.active_player.name,
							coords,
							roll,
							bliz_state]))
				if not Global.mp_enabled:
					game.print_data_to_game(result)
				elif mp_player_source:
					game.print_data_to_game.rpc(result)
					_on_mpui_input.rpc(coords,claim_slot,mp_start_type,update,terain,force_do,blz_fired,did_claim,[ran_attacker,ran_defender])
			return changed
		#else:
			#print("Failed to place a tile as the coords given: {0}, are outside map boundrys".format([coords]))
	#else:
		#print("Failed to place a tile as wasn't spesifed a coord")
	return false

## Checks if a tile can be claimed. Returns true if claimable.
func check_tile_claimably(coords:Vector2i,claim,test_suroundings=false,wants_tile_data=false,blz_fired=false,no_emition=false):
	
	var claim_colour = claim
	var claim_slot = claim
	
	if not claim is int and claim is ClaimData:
		claim_colour = claim.claim_colour
		claim_slot = claim.claim_turn_slot
	elif not claim is int and not claim is ClaimData:
		print_rich("[color=red][b]ERROR (method 'check_tile_claimably'):[/b] Claim paramater was not a Int or a ClaimData.[/color]")
		return false
	
	var tile = tile_data.new()
	var has_neighbors = find_linked_tiles(coords,check_claim_captatal(claim_colour),claim_colour)
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
		tile = start_search(tile,coords,claim_slot)
	# UNACESSABLE TILE
	if picked_tile == null:
		# DATA
		tile.type = -1
	
	# Self owned tile.
	elif picked_tile.get_custom_data("ownership") == claim_colour:
		# DATA
		tile.type = 2
		tile.opposite_claim = game.claims[claim_slot].name
		var neighbors = main_grid.get_surrounding_cells(coords)
		if picked_tile.get_custom_data("type") == 1:
			tile.tile_type = "capital"
			tile.points += 1
		elif picked_tile.get_custom_data("type") == 3:
			tile.tile_type = "fuel"
			tile.points -= 2
		#var cap_buff = 0
		var cap_debuff = 1
		#var caps_linked : Array[Vector2i]
		for neighbor in neighbors:
			picked_tile = main_grid.get_cell_tile_data(neighbor)
			if not picked_tile == null:
				if picked_tile.get_custom_data("ownership") == claim_colour:
					if picked_tile.get_custom_data("type") == 0:
						tile.points += 1
					elif picked_tile.get_custom_data("type") == 1:
						tile.points += 1
					elif picked_tile.get_custom_data("type") == 3:
						tile.points -= 1
		if cap_debuff == 0: #  and not (Global.cdan_enabled and tile.opposite_claim_data.claim_dangered)
			tile.points -= 10
		elif Global.cdan_enabled and game.active_player != null and game.active_player.orginal_claim.claim_dangered > 0:
			tile.points += game.active_player.orginal_claim.claim_dangered
		tile.fuel = mini(4,(check_claim_fuel_tile_count(claim_colour)))
	
	# Enemy owned tile.
	elif picked_tile.get_custom_data("ownership") != 0:
		
		# The most messest ways to write this, it work though.
		var oppose_claim = picked_tile.get_custom_data("ownership")
		tile.type = 1
		tile.opposite_claim_data = game.claims_order[oppose_claim-1]
		tile.opposite_claim = tile.opposite_claim_data.name
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
		var cap_debuff = 0
		var caps_linked : Array[Vector2i]
		for neighbor in neighbors:
			picked_tile = main_grid.get_cell_tile_data(neighbor)
			if not picked_tile == null:
				# if this is one of the player claims.
				if picked_tile.get_custom_data("ownership") == claim_colour:
					tile.points += 1
					count += 1
					# Tracks how meny capitals
					for x in check_claim_captatal(claim_colour).filter(func(_coords): return not _coords in caps_linked):
						tested_tiles = []
						if find_linked_tiles(tile.coords,[x],claim_slot,8):
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
					for x in check_claim_captatal(oppose_claim).filter(func(_coords): return not _coords in caps_linked):
						tested_tiles = []
						if find_linked_tiles(tile.coords,[x],oppose_claim,16):
							caps_linked.append(x)
							cap_debuff += 1
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
			
			if check_claim_captatal(claim_colour).size() == 1 and Global.cls_enabled:
				tile.points += Global.cls_boost
				count += Global.cls_boost
			
			if check_claim_captatal(oppose_claim).size() == 1 and Global.cls_enabled:
				tile.oppose_points += Global.cls_boost
				count -= Global.cls_boost
			# If the tile isn't conected to a capital, then it gets a -10 debuff to reward cutting off areas.
			if cap_debuff == 0: #  and not (Global.cdan_enabled and tile.opposite_claim_data.claim_dangered)
				tile.oppose_points -= 10
				count += 10
			elif Global.cdan_enabled and tile.opposite_claim_data.claim_dangered > 0:
				tile.oppose_points += tile.opposite_claim_data.claim_dangered
				count -= tile.opposite_claim_data.claim_dangered
			if Global.blz_enabled and blz_fired:
				tile.points += Global.blz_move_requrement * 10
				count += Global.blz_move_requrement * 10
			#elif cap_buff >= 2:
				#tile.oppose_points += 1
				#count += 1
		#elif Global.cdan_enabled and tile.opposite_claim_data.claim_dangered > 0:
			#tile.oppose_points += tile.opposite_claim_data.claim_dangered
			#count -= tile.opposite_claim_data.claim_dangered
		@warning_ignore("integer_division")
		tile.fuel = mini(4,(check_claim_fuel_tile_count(claim_colour)/2))
		tile.oppose_fuel = mini(4,(check_claim_fuel_tile_count(oppose_claim)))
		@warning_ignore("integer_division")
		count += tile.fuel - tile.oppose_fuel
		tile.final_score = count
		if Global.bran_enabled and count > -10 and has_neighbors:
			tile.available = true
		elif count >= 0 and has_neighbors:
			tile.available = true
		
	# Wall tile.
	elif picked_tile.get_custom_data("ownership") == 0 and picked_tile.get_custom_data("type") == 1: # main_grid.get_cell_atlas_coords(coords) == Vector2i(0,1)
		tile.type = 3
	
	# Empty tile.
	else:
		# check if it is a fuel tile
		if picked_tile.get_custom_data("type") == 3:
			tile.tile_type = "fuel"
		var neighbors = main_grid.get_surrounding_cells(coords)
		if has_neighbors:
			for neighbor in neighbors:
				picked_tile = main_grid.get_cell_tile_data(neighbor)
				
				if not picked_tile == null:
					if picked_tile.get_custom_data("ownership") == claim_colour:
						tile.available = true
	
	# RESULT
	if wants_tile_data:
		return tile
	if not no_emition: tile_info.emit(tile)
	return tile.available

#blz Was for blizing
#func check_tile_blizablity(coords:Vector2i,claim:int,test_suroundings=false):
	#var tile : tile_data = check_tile_claimably(coords,claim,test_suroundings,true,true)
	#if tile.type == 2 and tile.available:
		#pass


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
									else:
										return false
			elif not ignore_neighbor:
				return false
		return true
	else:
		return false



# COLLECT INFO

## Gets all avaliable tile around a claim.
func get_all_avalable_tiles(claim,search_for_value=true,ignore_set:Array[Vector2i]=[]) -> Array[tile_data]:
	var claimed_tiles : Array[tile_data]
	
	var claim_slot = claim
	
	if not claim is int and claim is ClaimData:
		claim_slot = claim.claim_turn_slot
	elif not claim is int and not claim is ClaimData:
		print_rich("[color=red][b]ERROR (method 'check_tile_claimably'):[/b] Claim paramater was not a Int or a ClaimData.[/color]")
		return claimed_tiles
	
	
	# gets the hole grid.
	var colection = main_grid.get_used_cells()
	# the loop that looks arround
	for tile in colection:
		if not tile in ignore_set:
			if check_tile_claimably(tile,claim):
				var new_tile = tile_data.new()
				new_tile.coords = tile
				
				if search_for_value:
					new_tile = start_search(new_tile,tile,claim_slot,ignore_set,60.0)
				
				claimed_tiles.append(new_tile)
	broke_timer = false
	return claimed_tiles

## Gets all avaliable tiles around a tile. See [method board.get_all_avalable_tiles] for more info.
func get_all_local_avalable_tiles(coords,claim,search_for_value=true,ignore_set:Array[Vector2i]=[],distance=1) -> Array[tile_data]:
	
	var claimed_tiles : Array[tile_data]
	
	var claim_slot = claim
	
	if not claim is int and claim is ClaimData:
		claim_slot = claim.claim_turn_slot
	elif not claim is int and not claim is ClaimData:
		print_rich("[color=red][b]ERROR (method 'check_tile_claimably'):[/b] Claim paramater was not a Int or a ClaimData.[/color]")
		return claimed_tiles
	
	var neighbors = main_grid.get_surrounding_cells(coords)
	for neighbor in neighbors:
		if not neighbor in ignore_set:
			if check_tile_claimably(neighbor,claim):
				var new_tile = tile_data.new()
				new_tile.coords = neighbor
				
				if search_for_value:
					new_tile = start_search(new_tile,neighbor,claim_slot,ignore_set,120.0)
				
				claimed_tiles.append(new_tile)
				if distance != 1:
					claimed_tiles.append_array(get_all_local_avalable_tiles(neighbor,claim,search_for_value,ignore_set,distance-1))
	broke_timer = false
	return claimed_tiles

func start_search(new_tile:tile_data,coords:Vector2i,claim:int,ignore_set:Array[Vector2i]=[],stop_time=-1.0) -> tile_data:
	# The ai personaltys
	var ai_data : ClaimData = game.claims_order[claim-1] if claim > 0 else game.claims[claim]
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
			
			if not picked_tile.get_custom_data("ownership") in [0,claim] and check_tile_claimably(coords,claim,false,false,false,true):
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
						score += search_surounding_tiles(neighbor,distance-1,claim,ignore_set,can_use_ai,ai_data,start_time,time_limit_s-burnup)
		elif time_cur >= time_limit_s and time_limit_s >= 0 and not broke_timer: 
			print("timer broke. :( \nTime was: ",time_cur)
			broke_timer = true
	return score

## Finds if two points are linked, normaly one tile, and its capital.
func find_linked_tiles(tile:Vector2i,other:Array[Vector2i],claim,limit=-1) -> bool:
	var answer = false
	
	# Makes sure that it is not in the tested tiles and or that it has hit its limit.
	if not tile in tested_tiles and limit != 0:
		var neighbors = main_grid.get_surrounding_cells(tile)
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
