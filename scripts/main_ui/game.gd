extends BoxContainer

@export var claims : Array[ClaimData]

var player_claim : PlayerClaim

@onready var board_ui = %board
@onready var next_turn = %next_turn
@onready var tile_info = %tile_Info
@onready var game_info = %game_Info
@onready var claims_info = %claims_Info
@onready var clock = %clock

func _ready():
	game_state_changed(true)

func on_next_turn():
	for claim in claims:
		claim.claim_dead = board_ui.check_claim_captatal(claim.claim_colour) == Vector2i(9999999,9999999)
		if claim is NonPlayerClaim and claim.claim_dead == false:
			while claim.moves > 0:
				var target = claim.claim_surounding_tiles(board_ui.get_all_avalable_tiles(claim.claim_colour))
				board_ui.on_claim_tile(target,claim.claim_colour)
				claim.moves -= 1
				clock.start()
				await clock.timeout
	game_state_changed(true)

func game_state_changed(refresh=false):
	claims_info.clear()
	var claim_text = "The Claims\n"
	for claim in claims:
		claim.claim_dead = board_ui.check_claim_captatal(claim.claim_colour) == Vector2i(9999999,9999999)
		if claim.claim_dead == false:
			claim.tile_size = board_ui.check_claim_tile_count(claim.claim_colour)
			claim.fuel_count = board_ui.check_claim_fuel_tile_count(claim.claim_colour)
			claim_text += claim.get_data()
			if refresh:
				claim.refresh()
				claim.capatal_tile = board_ui.check_claim_captatal(claim.claim_colour)
			if claim is PlayerClaim:
				if player_claim == null or refresh:
					player_claim = claim.duplicate()
					player_claim.tile_size = claim.tile_size
				if player_claim.tile_size < claim.tile_size and player_claim.moves > 0:
					player_claim.moves -= 1
					claim.moves -= 1
	
	if player_claim != null:
		claim_text += "----------\nYou have {0} moves left".format([player_claim.moves])
		
		if player_claim.moves == 0:
			board_ui.off_input = true
		else:
			board_ui.off_input = false
	
	claims_info.text = claim_text


func _on_board_tile_info(data:tile_data):
	tile_info.text = data.get_info()


func new_game():
	get_tree().change_scene_to_file("res://levels/menu.tscn")
