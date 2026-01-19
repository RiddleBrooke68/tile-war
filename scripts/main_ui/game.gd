extends BoxContainer
class_name game_manger

signal mp_back_to_lobby()


#mp Used to lookup pc and npc claims
## Used to lookup pc and npc claims
@export var claim_lookup : claim_lookup_table

## Which claims are on the board.
@export var claims : Array[ClaimData]

@export var panels : Array[ClaimDataPanel]

#mp This would replace player_claim
#mp [code] var active_player : PlayerClaim [/code]
var active_player : ClaimData:
	set(i):
		if i != null:
			print(i.name)
		active_player = i


@onready var board_ui = %board
@onready var next_turn = %next_turn
@onready var tile_info = %tile_Info
@onready var game_info = %game_Info
@onready var claims_info = %claims_Info
@onready var clock = %clock
@onready var fade_anim = %fade_anim


@onready var moves_plate = %moves_plate
## Tracks the current turn
var turn = 0
## Used when we need to display the current turn.
const turn_text = "Turn {0}"



## Just playes music.
var music : AudioStreamPlayer

func _ready():
	#mp I would probably need to get the set for who are players, who are bots, we don't realy need to know if their disabled or not, as their capitals won't spawn.
	#mp And set them up with the [code]claims[/code]
	#mp So cross refrence from Global.claim_list
	for i in range(Global.claim_list.size()):
		if Global.claim_list[i] == 2:
			claims[i] = claim_lookup.pc_claim_data[i]
			claims[i].name = Global.claim_names[i] if Global.claim_names[i] != "" or Global.claim_names.filter(func(_names): return _names == Global.claim_names[i]).size() <= 1 else claims[i].name
			if Global.mp_enabled:
				for x in Global.mp_player_list.keys():
					if i == Global.mp_player_list[x].current_claim - 1:
						claims[i].name = Global.mp_player_list[x].name
						claims[i].claim_mp_ip_linked = x
		else:
			claims[i] = claim_lookup.npc_claim_data[i]
		panels[i].claim = claims[i]
	music = AudioStreamPlayer.new()
	add_child(music)
	music.volume_linear = Global.music_vol/10
	music.stream = load(Global.music_list[Global.music_type]) as AudioStream
	music.play()
	game_state_changed(true)


var continue_turn = false
## Records what move where taken.
var done_moves : Array[Vector2i]
@rpc("any_peer")
## Goes to next turn and goes though all the AI's
func on_next_turn(mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		on_next_turn.rpc(false)
	active_player.claim_had_turn = true
	next_turn.disabled = true
	continue_turn = false
	print("Start Next turn:")
	for claim : ClaimData in claims:
		print("""----------------------------------------\nThe {0} turn""".format([claim.name]))
		print(claim.get_data())
		claim.claim_dead = board_ui.check_claim_captatal(claim.claim_colour).is_empty()
		if claim.claim_dead == false and claim.claim_had_turn == false and claim.name != active_player.name:
			
			
			if claim is NonPlayerClaim and claim.claim_dead == false:
				set_active_player(claim)
				#if Global.cdan_enabled and claim.claim_dangered:
					#claim.claim_dangered = false
				#claim.claim_active = true
				#active_player = claim.duplicate()
				#active_player.tile_size = claim.tile_size
				#moves_plate.colour = claim.claim_colour
				claim.claim_had_turn = true
				# Scans the available moves
				var colection : Array[tile_data] = board_ui.get_all_avalable_tiles(claim.claim_colour)
				# Only the host should give the ai movement.
					# Loops through untill it has no more moves
				while claim.moves > 0:
					if not Global.mp_enabled or (Global.mp_enabled and Global.mp_host):
						var target : tile_data = claim.claim_surounding_tiles(colection)
						if target != null and claim.moves > 0:
							colection.erase(target)
							done_moves.append_array(
								colection.filter(
									func(thing:tile_data) -> bool: return true if not thing.coords in done_moves else false).map(
									func(thing:tile_data) -> Vector2i: return thing.coords))
							#print(done_moves)
							board_ui.on_claim_tile(target.coords,claim.claim_colour)
							colection.append_array(board_ui.get_all_local_avalable_tiles(target.coords,claim.claim_colour,done_moves))
							#active_player.moves -= 1
							#claim.moves -= 1
							#mp_sync_movement.rpc(claims.find(claim),claim.moves,true)
							remove_active_player_moves(1,false,true)
						else:
							#active_player.moves = 0
							#claim.moves = 0
							#mp_sync_movement.rpc(claims.find(claim),claim.moves,true)
							remove_active_player_moves(0,true,true)
						print(active_player.moves)
						gui_board_events()
					clock.start()
					await clock.timeout
					
				claim.claim_active = false
				done_moves.clear()
			
			
			#mp If it reads a player, it gives them a turn if they haven't had one.
			elif claim is PlayerClaim:
				set_active_player(claim)
				#if Global.cdan_enabled and claim.claim_dangered:
					#claim.claim_dangered = false
				#claim.claim_active = true
				#active_player = claim.duplicate()
				#active_player.tile_size = claim.tile_size
				#moves_plate.colour = claim.claim_colour
				continue_turn = true
				break
		
		
		elif claim.claim_dead == false and claim.claim_had_turn == false and claim.name == active_player.name:
			claim.claim_had_turn = active_player.claim_had_turn
			claim.claim_active = false
	
	
	next_turn.disabled = false
	if not continue_turn:
		game_state_changed(true)
	else:
		game_state_changed()

@rpc("any_peer")
func mp_sync_movement(claim:int,moves : int,active_afected=false):
	if claims[claim].moves != moves:
		claims[claim].moves = moves
		#print("{0} client has been told by host that claim {1} has: {2} number of moves".format([Global.mp_player_list[Global.mp_player_id].name,claims[claim].name,claims[claim].moves]))
		if active_player == null:
			print_rich("[color=red]ERROR: the active player hasn't been set before atempts of syncing it.[/color]")
			set_active_player(claims[claim])
		gui_board_events()
	if active_player == claims[claim]:
		active_player = claims[claim]
	if active_afected and active_player.moves != moves:
		active_player.moves = moves
	game_state_changed(false,false)

@rpc("any_peer")
func mp_sync_host(id:int,claim:int):
	mp_sync_movement.rpc_id(id,claim,claims[claim].moves,true)

#bran removes a move if set to true
var failed_move = false
## Counts how meny claims that are dead, if 3,ie... all but one claim is alive, the game is over and the player must hit new game if lms is enabled.[br]
## See [member Global.lms_enabled] and [method game_manger.game_state_changed]
var dead_number = 0
## Updates the game when something happens.
func game_state_changed(refresh=false,set_active=true):
	#claims_info.clear()
	if refresh:
		active_player = null
	var claim_text = "The Claims\n"
	var bot_first_in_turn_order = false
	var there_is_players = false
	for claim in claims:
		claim.claim_dead = board_ui.check_claim_captatal(claim.claim_colour).is_empty()
		if claim.claim_dead == false:
			dead_number += 1
			claim.tile_size = board_ui.check_claim_tile_count(claim.claim_colour)
			claim.fuel_count = board_ui.check_claim_fuel_tile_count(claim.claim_colour)
			claim_text += claim.get_data()
			claim.capatal_tile = board_ui.check_claim_captatal(claim.claim_colour).duplicate()
			if not active_player == null:
				link_up_active_player(claim)
			if refresh:
				#if Global.cdan_enabled and claim.claim_dangered:
					#claim.claim_dangered = false
				claim.claim_had_turn = false
				if Global.mp_enabled and Global.mp_host:
					mp_sync_movement.rpc(claims.find(claim),claim.refresh(turn))
				elif not Global.mp_enabled:
					claim.refresh(turn)
				#if Global.mp_enabled:
					#print("{0} client belives this claim {1} has: {2} number of moves".format([Global.mp_player_list[Global.mp_player_id].name,claim.name,claim.moves]))
			if claim is PlayerClaim and set_active: #mp 
				if ((claim.claim_had_turn == false and active_player == null) or active_player.name == claim.name) and not bot_first_in_turn_order: # and (active_player.name == claim.name or active_player == null):
					if active_player == null or refresh:
						set_active_player(claim)
						#if Global.cdan_enabled and claim.claim_dangered:
							#claim.claim_dangered = false
						#claim.claim_active = true
						#active_player = claim.duplicate()
						#active_player.tile_size = claim.tile_size
						#moves_plate.colour = claim.claim_colour
					#if (active_player.tile_size != claim.tile_size or failed_move) and active_player.moves > 0:
						#failed_move = false
						#active_player.moves -= 1
						#claim.moves -= 1
						#if Global.mp_enabled and Global.mp_host:
							#mp_sync_movement.rpc(claims.find(claim),claim.moves,true)
						#elif Global.mp_enabled:
							#mp_sync_host.rpc_id(1,Global.mp_player_id,claims.find(claim))
						#remove_active_player_moves()
				# Alowing bots to go first
				elif bot_first_in_turn_order:
					there_is_players = true
			elif claim is NonPlayerClaim and set_active and ((claim.claim_had_turn == false and active_player == null) or active_player.name == claim.name):
				if active_player == null or refresh:
					bot_first_in_turn_order = true
					#if not Global.mp_enabled or Global.mp_host:
						#on_next_turn()
	if refresh:
		turn += 1
		if ((active_player == null and not bot_first_in_turn_order) or (bot_first_in_turn_order and not there_is_players)) and not Global.mp_enabled:
			active_player = PlayerClaim.new()
			active_player.claim_colour = 0
			moves_plate.colour = active_player.claim_colour
		elif (bot_first_in_turn_order and there_is_players):
			active_player = PlayerClaim.new()
			on_next_turn()
			return
	#mp should be fine.
	if active_player != null: 
		if Global.mp_enabled and Global.mp_host:
			mp_sync_movement.rpc(claims.find(active_player),active_player.moves,true)
		claim_text += "----------\nYou have {0} moves left".format([active_player.moves])
		#%test_player_data.claim = player_claim
		#%test_player_data.update()
		
		if active_player.moves == 0 or active_player is NonPlayerClaim:
			board_ui.off_input = true
		elif Global.mp_enabled and not active_player.claim_mp_ip_linked in [Global.mp_player_id,0]:
			board_ui.off_input = true
			next_turn.disabled = true
		else:
			board_ui.off_input = false
	
	claims_info.text = claim_text
	if dead_number == 1 and Global.lms_enabled:
		winers_name.text = active_player.name
		win_animiate.play("win")
		next_turn.disabled = true
	else:
		dead_number = 0
	if active_player != null:
		moves_plate.number = active_player.moves
		moves_plate.update_plate_display()

@onready var winers_name = %"winers name"
@onready var win_animiate = %win_animiate

# EXTRA ACTIONS
@onready var game_event_recorder = %game_event_recorder
@onready var chat_mode = %chat_mode
@onready var chat_input = %chat_input
var game_event_text = ""
@rpc("any_peer")
func print_data_to_game(_str,mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		print_data_to_game.rpc(_str,false)
	game_event_text += _str+"\n"
	game_event_recorder.text = game_event_text


func _on_chat_input_text_submitted(new_text):
	var colour_claim = Global.mp_claims_colours[Global.mp_player_list[Global.mp_player_id].current_claim].to_html()
	if Global.mp_enabled:
		print_data_to_game("[color={2}][b]{0}:[/b][/color] {1}".format([Global.mp_player_list[Global.mp_player_id].name,new_text,colour_claim]))
	else:
		print_data_to_game("[color={2}][b]{0}:[/b][/color] {1}".format([Global.claim_names[active_player.claim_colour-1],new_text,colour_claim]))
	chat_input.text = ""

## This currently oprates the move panel animation.
func gui_board_events():
	moves_plate.number = active_player.moves #mp active_player.moves.


func _on_board_tile_info(data:tile_data):
	tile_info.text = data.get_info()
	game_info.text = turn_text.format([turn])

## This changes the scene back to the main menu.
@rpc("any_peer")
func new_game(mp_player_source=true):
	for claim in claims:
		claim.tile_size = 0
		claim.fuel_count = 0
		claim.capatal_tile = []
		claim.claim_dead = false
		claim.claim_active = false
		claim.claim_had_turn = false
		claim.claim_dangered = 0
		claim.moves = 0
	if Global.mp_enabled and mp_player_source:
		new_game.rpc(false)
	fade_anim.play("fade_out")
	var tween = get_tree().create_tween()
	tween.tween_property(music,"volume_linear",0.0,3.0)


func _on_fade_anim_animation_finished(anim_name):
	if anim_name == "fade_out":
		if Global.mp_enabled:
			mp_back_to_lobby.emit()
		else:
			get_tree().change_scene_to_file("res://levels/menu.tscn")

func set_active_player(claim:ClaimData):
	if not active_player == null:
		for i in active_player.move_made.get_connections():
			active_player.move_made.disconnect(i.callable)
	#if Global.cdan_enabled and claim.claim_dangered:
		#claim.claim_dangered = false
	claim.claim_active = true
	active_player = claim.duplicate()
	active_player.orginal_claim = claim
	active_player.tile_size = claim.tile_size
	moves_plate.colour = claim.claim_colour

func link_up_active_player(claim:ClaimData):
	if not active_player.move_made.is_connected(claim.depleate_danger_value):
		active_player.move_made.connect(claim.depleate_danger_value)

func remove_active_player_moves(incremts:int=1,set_as=false,bot_only=false):
	if active_player.moves - incremts < 0 or active_player.orginal_claim.moves - incremts < 0 or incremts < 0 and set_as:
		return
	failed_move = false
	if not set_as:
		active_player.moves -= incremts
		active_player.orginal_claim.moves -= incremts
	else:
		active_player.moves = incremts
		active_player.orginal_claim.moves = incremts
	if not bot_only:
		if Global.mp_enabled: #and Global.mp_host:
			mp_sync_movement.rpc(claims.find(active_player.orginal_claim),active_player.orginal_claim.moves,true)
		#elif Global.mp_enabled:
			#mp_sync_host.rpc_id(1,Global.mp_player_id,claims.find(active_player.orginal_claim))
	else:
		mp_sync_movement.rpc(claims.find(active_player.orginal_claim),active_player.orginal_claim.moves,true)
