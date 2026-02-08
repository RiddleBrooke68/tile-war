extends Control

@onready var profile_loader = $profile_loader

func _on_profile_loader_profile_request_save():
	profile_loader.save_profile(save_profile_data())

func _on_profile_loader_profile_selected(data):
	load_profile_data(data)

# test function
func load_profile_data(profile:Dictionary):
	# map type
	if profile.keys().has("map") and profile.map is int:
		Global.map_type = profile.map
	# Wall count
	if profile.keys().has("wall") and profile.wall is int:
		Global.wall_count = profile.wall
	# Fuel count
	if profile.keys().has("fuel") and profile.fuel is int:
		Global.fuel_count = profile.fuel
	# Cap count
	if profile.keys().has("cap") and profile.cap is Array[int]:
		Global.cap_list = profile.cap
	# Claim set
	if profile.keys().has("claim") and profile.claim is Array[int]:
		Global.claim_list = profile.claim
	# Ai level
	if profile.keys().has("ai") and profile.ai is int:
		Global.ai_level = profile.ai
	# music type
	if profile.keys().has("mus") and profile.mus is int:
		Global.music_type = profile.mus
	# LMS setting
	if profile.keys().has("lms") and profile.lms is bool:
		Global.lms_enabled = profile.lms
	# Bran setting
	if profile.keys().has("bran") and profile.bran is bool:
		Global.bran_enabled = profile.bran
	# Cdan setting
	if profile.keys().has("cdan_e") and profile.cdan_e is bool:
		Global.cdan_enabled = profile.cdan_e
	# cdan_duration setting
	if profile.keys().has("cdan_d") and profile.cdan_d is int:
		Global.cdan_duration = profile.cdan_d
	# cdan_capture_duration setting
	if profile.keys().has("cdan_cd") and profile.cdan_cd is int:
		Global.cdan_capture_duration = profile.cdan_cd
	# blz setting
	if profile.keys().has("blz_e") and profile.blz_e is bool:
		Global.blz_enabled = profile.blz_e
	# blz_move_requrement setting
	if profile.keys().has("blz_mr") and profile.blz_mr is int:
		Global.blz_move_requrement = profile.blz_mr
	
	if profile.keys().has("move_settings") and profile.move_settings is Dictionary:
		if profile.move_settings.keys().has("tile_int_r") and profile.move_settings.tile_int_r is int:
			Global.moves_tile_int_reduction_boost = 	profile.move_settings.tile_int_r
		if profile.move_settings.keys().has("tile_int_l") and profile.move_settings.tile_int_l is int:
			Global.moves_tile_int_lim_boost = 			profile.move_settings.tile_int_l
		
		if profile.move_settings.keys().has("tile_sec_r") and profile.move_settings.tile_sec_r is int:
			Global.moves_tile_second_reduction_boost = 	profile.move_settings.tile_sec_r
		if profile.move_settings.keys().has("tile_sec_l") and profile.move_settings.tile_sec_l is int:
			Global.moves_tile_second_lim_boost = 		profile.move_settings.tile_sec_l
		
		if profile.move_settings.keys().has("fuel_r") and profile.move_settings.fuel_r is int:
			Global.moves_fuel_reduction_boost = 		profile.move_settings.fuel_r
		if profile.move_settings.keys().has("fuel_l") and profile.move_settings.fuel_l is int:
			Global.moves_fuel_lim_boost = 				profile.move_settings.fuel_l
		
		if profile.move_settings.keys().has("turn_r") and profile.move_settings.turn_r is int:
			Global.moves_turn_reduction_boost = 		profile.move_settings.turn_r
		if profile.move_settings.keys().has("turn_l") and profile.move_settings.turn_l is int:
			Global.moves_turn_lim_boost = 				profile.move_settings.turn_l
	

## Dev only function
func save_profile_data(mp_for_client=false) -> Dictionary:
	var data = {}
	# map type
	data["map"] = Global.map_type
	# Wall count
	data["wall"] = Global.wall_count
	# Fuel count
	data["fuel"] = Global.fuel_count
	# Cap count
	data["cap"] = Global.cap_list
	# Claim set
	data["claim"] = Global.claim_list
	# Ai level
	data["ai"] = Global.ai_level
	# LMS setting
	data["lms"] = Global.lms_enabled
	# Bran setting
	data["bran"] = Global.bran_enabled
	# Cdan setting
	data["cdan_e"] = Global.cdan_enabled
	# cdan_duration setting
	data["cdan_d"] = Global.cdan_duration
	# cdan_capture_duration setting
	data["cdan_cd"] = Global.cdan_capture_duration
	# blz setting
	data["blz_e"] = Global.blz_enabled
	# blz_move_requrement setting
	data["blz_mr"] = Global.blz_move_requrement
	
	data["move_settings"] = {
		"tile_int_r":Global.moves_tile_int_reduction_boost,
		"tile_int_l":Global.moves_tile_int_lim_boost,
		
		"tile_sec_r":Global.moves_tile_second_reduction_boost,
		"tile_sec_l":Global.moves_tile_second_lim_boost,
		
		"fuel_r":Global.moves_fuel_reduction_boost,
		"fuel_l":Global.moves_fuel_lim_boost,
		
		"turn_r":Global.moves_turn_reduction_boost,
		"turn_l":Global.moves_turn_lim_boost
		}
	if mp_for_client:
		# music type
		data["mus"] = Global.music_type
	return data
