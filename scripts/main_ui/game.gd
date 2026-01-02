extends BoxContainer

@export var claims : Array[ClaimData]

var player_claim : PlayerClaim

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

var music : AudioStreamPlayer

func _ready():
	music = AudioStreamPlayer.new()
	add_child(music)
	music.volume_linear = Global.music_vol/10
	music.stream = load(Global.music_list[Global.music_type]) as AudioStream
	music.play()
	game_state_changed(true)
	moves_plate.number = player_claim.moves
	moves_plate.update_plate_display()

var done_moves : Array[Vector2i]
func on_next_turn():
	next_turn.disabled = true
	print("Start Next turn:")
	for claim : ClaimData in claims:
		print("""----------------------------------------\nThe {0} turn""".format([claim.name]))
		claim.claim_dead = board_ui.check_claim_captatal(claim.claim_colour).is_empty()
		if claim is NonPlayerClaim and claim.claim_dead == false:
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
					claim.moves -= 1
				else:
					claim.moves = 0
				clock.start()
				await clock.timeout
			done_moves.clear()
	next_turn.disabled = false
	game_state_changed(true)
	moves_plate.number = player_claim.moves
	moves_plate.update_plate_display()

var dead_number = 0
func game_state_changed(refresh=false):
	#claims_info.clear()
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
				claim.refresh(turn)
			if claim is PlayerClaim:
				if player_claim == null or refresh:
					player_claim = claim.duplicate()
					player_claim.tile_size = claim.tile_size
				if player_claim.tile_size < claim.tile_size and player_claim.moves > 0:
					player_claim.moves -= 1
					claim.moves -= 1
	if refresh:
		turn += 1
	if player_claim != null:
		claim_text += "----------\nYou have {0} moves left".format([player_claim.moves])
		#%test_player_data.claim = player_claim
		#%test_player_data.update()
		
		if player_claim.moves == 0:
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
	moves_plate.number = player_claim.moves


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
