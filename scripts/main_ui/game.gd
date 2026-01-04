extends BoxContainer
class_name game_manger

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
		else:
			claims[i] = claim_lookup.npc_claim_data[i]
		panels[i].claim = claims[i]
	music = AudioStreamPlayer.new()
	add_child(music)
	music.volume_linear = Global.music_vol/10
	music.stream = load(Global.music_list[Global.music_type]) as AudioStream
	music.play()
	game_state_changed(true)
	moves_plate.number = active_player.moves
	moves_plate.update_plate_display()


var continue_turn = false
## Records what move where taken.
var done_moves : Array[Vector2i]
## Goes to next turn and goes though all the AI's
func on_next_turn():
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
				claim.claim_active = true
				active_player = claim.duplicate()
				active_player.tile_size = claim.tile_size
				moves_plate.colour = claim.claim_colour - 1
				claim.claim_had_turn = true
				# Scans the available moves
				var colection : Array[tile_data] = board_ui.get_all_avalable_tiles(claim.claim_colour)
				
				# Loops through untill it has no more moves
				while claim.moves > 0:
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
						active_player.moves -= 1
						claim.moves -= 1
					else:
						active_player.moves = 0
						claim.moves = 0
					gui_board_events()
					clock.start()
					await clock.timeout
				
				claim.claim_active = false
				done_moves.clear()
			#mp If it reads a player, it gives them a turn if they haven't had one.
			elif claim is PlayerClaim:
				claim.claim_active = true
				active_player = claim.duplicate()
				active_player.tile_size = claim.tile_size
				moves_plate.colour = claim.claim_colour - 1
				continue_turn = true
				break
		elif claim.claim_dead == false and claim.claim_had_turn == false and claim.name == active_player.name:
			claim.claim_had_turn = active_player.claim_had_turn
			claim.claim_active = false
	next_turn.disabled = false
	if not continue_turn:
		game_state_changed(true)
		moves_plate.number = active_player.moves
		moves_plate.update_plate_display()
	else:
		game_state_changed()
		moves_plate.number = active_player.moves
		moves_plate.update_plate_display()

## Counts how meny claims that are dead, if 3,ie... all but one claim is alive, the game is over and the player must hit new game if lms is enabled.[br]
## See [member Global.lms_enabled] and [method game_manger.game_state_changed]
var dead_number = 0
## Updates the game when something happens.
func game_state_changed(refresh=false):
	#claims_info.clear()
	if refresh:
		active_player = null
	var claim_text = "The Claims\n"
	for claim in claims:
		claim.claim_dead = board_ui.check_claim_captatal(claim.claim_colour).is_empty()
		if claim.claim_dead == false:
			dead_number += 1
			claim.tile_size = board_ui.check_claim_tile_count(claim.claim_colour)
			claim.fuel_count = board_ui.check_claim_fuel_tile_count(claim.claim_colour)
			claim_text += claim.get_data()
			claim.capatal_tile = board_ui.check_claim_captatal(claim.claim_colour).duplicate() 
			if refresh:
				claim.claim_had_turn = false
				claim.refresh(turn)
			if claim is PlayerClaim: #mp 
				if ((claim.claim_had_turn == false and active_player == null) or active_player.name == claim.name): # and (active_player.name == claim.name or active_player == null):
					if active_player == null or refresh:
						claim.claim_active = true
						active_player = claim.duplicate()
						active_player.tile_size = claim.tile_size
						moves_plate.colour = claim.claim_colour - 1
					if active_player.tile_size != claim.tile_size and active_player.moves > 0:
						active_player.moves -= 1
						claim.moves -= 1
	if refresh:
		turn += 1
		if active_player == null:
			active_player = PlayerClaim.new()
	#mp should be fine.
	if active_player != null: 
		claim_text += "----------\nYou have {0} moves left".format([active_player.moves])
		#%test_player_data.claim = player_claim
		#%test_player_data.update()
		
		if active_player.moves == 0 or active_player is NonPlayerClaim:
			board_ui.off_input = true
		else:
			board_ui.off_input = false
	
	claims_info.text = claim_text
	if dead_number == 1 and Global.lms_enabled:
		next_turn.disabled = true
	else:
		dead_number = 0



# EXTRA ACTIONS

## This currently oprates the move panel animation.
func gui_board_events():
	moves_plate.number = active_player.moves #mp active_player.moves.


func _on_board_tile_info(data:tile_data):
	tile_info.text = data.get_info()
	game_info.text = turn_text.format([turn])

## This changes the scene back to the main menu.
func new_game():
	fade_anim.play("fade_out")
	var tween = get_tree().create_tween()
	tween.tween_property(music,"volume_linear",0.0,3.0)


func _on_fade_anim_animation_finished(anim_name):
	if anim_name == "fade_out":
		get_tree().change_scene_to_file("res://levels/menu.tscn")
