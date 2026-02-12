
## This controls the menu that the player uses for single and hot seat.
## However can be use for multiplayer. See [menu_mp_class]
extends Control
class_name menu_class

@onready var start_game_button = %start_game

@onready var map_setting = %map_setting

@onready var wall_text : Label = %wall_text
@onready var wall_slider : Slider = %WallSlider
@onready var fuel_text : Label = %fuel_text
@onready var fuel_slider : Slider = %FuelSlider
@onready var ai_level : OptionButton = %ai_level_setting

# Claims and their control.
@onready var green_claim_type : OptionButton = %green_claim_type
@onready var purple_claim_type : OptionButton = %purple_claim_type
@onready var yellow_claim_type : OptionButton = %yellow_claim_type
@onready var red_claim_type : OptionButton = %red_claim_type

@onready var green_name : LineEdit = %green_name
@onready var purple_name : LineEdit = %purple_name
@onready var yellow_name : LineEdit = %yellow_name
@onready var red_name : LineEdit = %red_name

@onready var extra_options = $Extra_options
@onready var profile_loader = $profile_loader

#@deprecated
#@onready var player_setting = $BoxContainer/GridContainer/player_setting
#@deprecated
#@onready var purple_setting = $BoxContainer/GridContainer/purple_setting
#@deprecated
#@onready var yellow_setting = $BoxContainer/GridContainer/yellow_setting
#@deprecated
#@onready var red_setting = $BoxContainer/GridContainer/red_setting

@onready var green_cap : OptionButton = %green_cap
@onready var plum_cap : OptionButton  = %plum_cap
@onready var york_cap : OptionButton = %york_cap
@onready var river_cap : OptionButton = %river_cap
@onready var cap_list : Array[OptionButton] = [green_cap,plum_cap,york_cap,river_cap]

@onready var music_type : OptionButton = $"BoxContainer3/BoxContainer/Music type/music_type_setting"
@onready var music_slider = $BoxContainer3/BoxContainer/music_settings/MusicSlider
@onready var sfx_slider = $BoxContainer3/BoxContainer/sfx_settings/SfxSlider

@onready var lms_setting : CheckBox = %lms_setting
@onready var bran_setting : CheckBox = %bran_setting
@onready var cdan_setting : CheckBox = %cdan_setting
@onready var cdan_text : Label = %cdan_text
@onready var cdan_slider : Slider = %CdanSlider
@onready var cdan_cd_text : Label = %cdan_cd_text
@onready var cdan_cd_slider : Slider = %CdanCdSlider
@onready var blz_setting : CheckBox = %blz_setting
@onready var blz_text : Label = %blz_text
@onready var blz_slider : Slider = %BlzSlider

@onready var tile_int_lim_input : LineEdit = %tile_int_lim_input
@onready var tile_int_reduct_input : LineEdit = %tile_int_reduct_input
@onready var tile_sec_lim_input : LineEdit = %tile_sec_lim_input
@onready var tile_sec_reduct_input : LineEdit = %tile_sec_reduct_input
@onready var fuel_lim_input : LineEdit = %fuel_lim_input
@onready var fuel_reduct_input : LineEdit = %fuel_reduct_input
@onready var turn_lim_input : LineEdit = %turn_lim_input
@onready var turn_reduct_input : LineEdit = %turn_reduct_input


## For game sounds. (CURRENTLY USING SOUNDS FROM GOD MACHINE)
var sound : AudioStreamPlayer


var music : AudioStreamPlayer

#var cmd_args = {}

func _ready(mp_is_updating=false):
	
	#for cmdline in OS.get_cmdline_args():
			#if cmdline.contains("="):
				#var key_value = cmdline.split("=")
				#cmd_args[key_value[0].trim_prefix("--")] = key_value[1]
			#else:
				# Options without an argument will be present in the dictionary,
				# with the value set to an empty string.
				#cmd_args[cmdline.trim_prefix("--")] = ""
	
	sound = AudioStreamPlayer.new()
	add_child(sound)
	sound_play()
	if music == null:
		music = AudioStreamPlayer.new()
		add_child(music)
		music_play()
	# Pregenration
	map_setting.selected = Global.map_type
	_on_map_setting_item_selected(map_setting.selected,false,true)
	# Genration
	wall_slider.value = Global.wall_count
	#_on_wall_slider_value_changed(wall_slider.value)
	fuel_slider.value = Global.fuel_count
	#_on_fuel_slider_value_changed(fuel_slider.value)
	cdan_slider.value = Global.cdan_duration
	#_on_cdan_slider_value_changed(cdan_slider.value)
	cdan_cd_slider.value = Global.cdan_capture_duration
	
	blz_slider.value = Global.blz_move_requrement
	#_on_blz_slider_value_changed(blz_slider.value)
	# Ai
	ai_level.selected = Global.ai_level
	# Active players
	green_claim_type.selected = Global.claim_list[0]
	purple_claim_type.selected = Global.claim_list[1]
	yellow_claim_type.selected = Global.claim_list[2]
	red_claim_type.selected = Global.claim_list[3]
	green_name.text = Global.claim_names[0]
	purple_name.text = Global.claim_names[1]
	yellow_name.text = Global.claim_names[2]
	red_name.text = Global.claim_names[3]
		#player_setting.button_pressed 	= Global.player_enabled
		#purple_setting.button_pressed 	= Global.purple_enabled
		#yellow_setting.button_pressed 	= Global.yellow_enabled
		#red_setting.button_pressed  	= Global.red_enabled
	# Cap number
	for i in range(0,4):
		cap_list[i].selected = Global.cap_list[i] - 1
	
	
	# Lms
	lms_setting.button_pressed = Global.lms_enabled
	# Bran
	bran_setting.button_pressed = Global.bran_enabled
	# Cdan
	cdan_setting.button_pressed = Global.cdan_enabled
	# Blz
	blz_setting.button_pressed = Global.blz_enabled
	
	# movement
	tile_int_lim_input.text = str(Global.moves_tile_int_lim_boost)
	tile_int_reduct_input.text = str(Global.moves_tile_int_reduction_boost)
	tile_sec_lim_input.text = str(Global.moves_tile_second_lim_boost)
	tile_sec_reduct_input.text = str(Global.moves_tile_second_reduction_boost)
	fuel_lim_input.text = str(Global.moves_fuel_lim_boost)
	fuel_reduct_input.text = str(Global.moves_fuel_reduction_boost)
	turn_lim_input.text = str(Global.moves_turn_lim_boost)
	turn_reduct_input.text = str(Global.moves_turn_reduction_boost)
	
	# Music
	music_type.selected = Global.music_type
	music_slider.value = Global.music_vol
	sfx_slider.value = Global.SFX_vol
	if not mp_is_updating:
		# Remove Multiplayer
		Global.mp_enabled = false
		Global.mp_host = false
		Global.mp_player_id = 0
		Global.mp_player_list.clear()


func sound_play(use_drag=false):
	if not use_drag or drag:
		sound.volume_linear = Global.SFX_vol/10
		sound.stream = load("res://audio/FX/left click sound.mp3") as AudioStream
		sound.play()

func music_play():
	if not music.playing:
		music.volume_linear = Global.music_vol/10
		music.stream = load("res://audio/music/placeholders/stolen/pvz_gw_lounge_lizard.ogg") as AudioStream
		music.play()

var drag = false

func drag_ended(value):
	drag = value

@rpc("any_peer")
func _on_map_setting_item_selected(index,mp_player_source=true,block=false):
	if Global.mp_enabled and mp_player_source:
		_on_map_setting_item_selected.rpc(index,false,block)
	map_setting.selected = index
	Global.map_type = index
	for i in range(0,4):
		if index == 0:
			if not block:
				cap_list[i].selected = 0
				Global.cap_list[i] = 1
			cap_list[i].set_item_disabled(1,false)
			cap_list[i].set_item_disabled(2,false)
			cap_list[i].set_item_disabled(3,true)
		elif index == 1:
			if not block:
				cap_list[i].selected = 1
				Global.cap_list[i] = 2
			cap_list[i].set_item_disabled(1,false)
			cap_list[i].set_item_disabled(2,false)
			cap_list[i].set_item_disabled(3,false)
		elif index == 2:
			if not block:
				cap_list[i].selected = 1
				Global.cap_list[i] = 2
			cap_list[i].set_item_disabled(1,false)
			cap_list[i].set_item_disabled(2,true)
			cap_list[i].set_item_disabled(3,true)
		elif index == 3:
			if not block:
				cap_list[i].selected = 1
				Global.cap_list[i] = 2
			cap_list[i].set_item_disabled(1,false)
			cap_list[i].set_item_disabled(2,true)
			cap_list[i].set_item_disabled(3,true)
	sound_play()

@rpc("any_peer")
func _on_wall_slider_value_changed(value,mp_player_source=true):
	# Multiplayer parts.
	if Global.mp_enabled and mp_player_source and Global.wall_count != value:
		wall_text.text = "Wall count: {0}".format([value])
		Global.wall_count = value
		_on_wall_slider_value_changed.rpc(value,false)
	elif Global.mp_enabled and wall_slider.value != value:
		wall_text.text = "Wall count: {0}".format([value])
		Global.wall_count = value
		wall_slider.value = value
	else:
		wall_text.text = "Wall count: {0}".format([value])
		Global.wall_count = value
	sound_play(true)

@rpc("any_peer")
func _on_fuel_slider_value_changed(value,mp_player_source=true):
	# Multiplayer parts.
	if Global.mp_enabled and mp_player_source and Global.fuel_count != value:
		fuel_text.text = "Fuel count: {0}".format([value])
		Global.fuel_count = value
		_on_fuel_slider_value_changed.rpc(value,false)
	elif Global.mp_enabled and fuel_slider.value != value:
		fuel_text.text = "Fuel count: {0}".format([value])
		Global.fuel_count = value
		fuel_slider.value = value
	else:
		fuel_text.text = "Fuel count: {0}".format([value])
		Global.fuel_count = value
	sound_play(true)

# Indviual Claim Settings

# Names everyyyyBODY!!!
@rpc("any_peer")
func _on_green_name_text_submitted(new_text,mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		_on_green_name_text_submitted.rpc(new_text,false)
	Global.claim_names[0] = new_text

@rpc("any_peer")
func _on_purple_name_text_submitted(new_text,mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		_on_purple_name_text_submitted.rpc(new_text,false)
	Global.claim_names[1] = new_text

@rpc("any_peer")
func _on_yellow_name_text_submitted(new_text,mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		_on_yellow_name_text_submitted.rpc(new_text,false)
	Global.claim_names[2] = new_text

@rpc("any_peer")
func _on_red_name_text_submitted(new_text,mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		_on_red_name_text_submitted.rpc(new_text,false)
	Global.claim_names[3] = new_text

# Who is who
#mp I would probably use a new set of option buttons.
#mp Ooh, and thats a thought, adding a name plate, so if you are playing as someone, you can use a custom name.

@rpc("any_peer")
func _on_green_claim_type_item_selected(index,mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		_on_green_claim_type_item_selected.rpc(index,false)
	green_claim_type.selected = index
	Global.claim_list[0] = index

@rpc("any_peer")
func _on_purple_claim_type_item_selected(index,mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		_on_purple_claim_type_item_selected.rpc(index,false)
	purple_claim_type.selected = index
	Global.claim_list[1] = index

@rpc("any_peer")
func _on_yellow_claim_type_item_selected(index,mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		_on_yellow_claim_type_item_selected.rpc(index,false)
	yellow_claim_type.selected = index
	Global.claim_list[2] = index

@rpc("any_peer")
func _on_red_claim_type_item_selected(index,mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		_on_red_claim_type_item_selected.rpc(index,false)
	red_claim_type.selected = index
	Global.claim_list[3] = index

#mp Would probably be rendered obslet if I were to go through with my changes.
# Enabled claims
func _on_player_setting_toggled(toggled_on):
	Global.player_enabled = toggled_on
	sound_play()
func _on_purple_setting_toggled(toggled_on):
	Global.purple_enabled = toggled_on
	sound_play()
func _on_yellow_setting_toggled(toggled_on):
	Global.yellow_enabled = toggled_on
	sound_play()
func _on_red_setting_toggled(toggled_on):
	Global.red_enabled = toggled_on
	sound_play()

@rpc("any_peer")
func _on_green_cap_item_selected(index,mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		_on_green_cap_item_selected.rpc(index,false)
	green_cap.selected = index
	Global.cap_list[0] = index + 1 
	sound_play()

@rpc("any_peer")
func _on_plum_cap_item_selected(index,mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		_on_plum_cap_item_selected.rpc(index,false)
	plum_cap.selected = index
	Global.cap_list[1] = index + 1
	sound_play()

@rpc("any_peer")
func _on_york_cap_item_selected(index,mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		_on_york_cap_item_selected.rpc(index,false)
	york_cap.selected = index
	Global.cap_list[2] = index + 1
	sound_play()

@rpc("any_peer")
func _on_river_cap_item_selected(index,mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		_on_river_cap_item_selected.rpc(index,false)
	river_cap.selected = index
	Global.cap_list[3] = index + 1
	sound_play()


func _on_start_game():
	get_tree().change_scene_to_file("res://levels/main_ui.tscn")

func _on_multiplayer_pressed():
	get_tree().change_scene_to_file("res://levels/menu_mp.tscn")

func _on_singleplayer_pressed():
	get_tree().change_scene_to_file("res://levels/menu.tscn")


@rpc("any_peer")
func _on_change_ai_level(index,mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		_on_change_ai_level.rpc(index,false)
	ai_level.selected = index
	Global.ai_level = index
	sound_play()

@rpc("any_peer")
func _on_music_type_setting_item_selected(index,mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		_on_music_type_setting_item_selected.rpc(index,false)
	music_type.selected = index
	Global.music_type = index
	sound_play()

#@rpc("any_peer")
func _on_music_slider_value_changed(value):
	# Multiplayer parts.
	#if Global.mp_enabled and mp_player_source and Global.music_vol != value:
		#Global.music_vol = value
		#_on_music_slider_value_changed.rpc(value,false)
	#elif Global.mp_enabled and fuel_slider.value != value:
		#Global.music_vol = value
		#music_slider.value = value
	#else:
	Global.music_vol = value
	sound_play(true)

#@rpc("any_peer")
## Sets the volume of sound efects
func _on_sfx_slider_value_changed(value):
	# Multiplayer parts.
	#if Global.mp_enabled and mp_player_source and Global.SFX_vol != value:
		#Global.SFX_vol = value
		#_on_sfx_slider_value_changed.rpc(value,false)
	#elif Global.mp_enabled and fuel_slider.value != value:
		#Global.SFX_vol = value
		#sfx_slider.value = value
	#else:
	Global.SFX_vol = value
	sound_play(true)

@rpc("any_peer")
func _on_lms_setting_toggled(toggled_on,mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		_on_lms_setting_toggled.rpc(toggled_on,false)
	lms_setting.button_pressed = toggled_on
	Global.lms_enabled = toggled_on
	sound_play()

@rpc("any_peer")
func _on_bran_setting_toggled(toggled_on,mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		_on_bran_setting_toggled.rpc(toggled_on,false)
	bran_setting.button_pressed = toggled_on
	Global.bran_enabled = toggled_on
	sound_play()

@rpc("any_peer")
func _on_cdan_setting_toggled(toggled_on,mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		_on_cdan_setting_toggled.rpc(toggled_on,false)
	cdan_setting.button_pressed = toggled_on
	Global.cdan_enabled = toggled_on
	sound_play()

@rpc("any_peer")
func _on_cdan_slider_value_changed(value,mp_player_source=true):
	# Multiplayer parts.cdan_slider.value
	if Global.mp_enabled and mp_player_source and Global.cdan_duration != int(value):
		cdan_text.text = "Capital protection duration: {0}".format([int(value)])
		Global.cdan_duration = int(value)
		_on_cdan_slider_value_changed.rpc(value,false)
	elif Global.mp_enabled and cdan_slider.value != int(value):
		cdan_text.text = "Capital protection duration: {0}".format([int(value)])
		Global.cdan_duration = int(value)
		cdan_slider.value = value
	else:
		cdan_text.text = "Capital protection duration: {0}".format([int(value)])
		Global.cdan_duration = int(value)
	sound_play(true)

@rpc("any_peer")
func _on_cdan_cd_slider_value_changed(value,mp_player_source=true):
	# Multiplayer parts.cdan_slider.value
	if Global.mp_enabled and mp_player_source and Global.cdan_capture_duration != int(value):
		cdan_cd_text.text = "Capital attacker protection duration: {0}".format([int(value)])
		Global.cdan_capture_duration = int(value)
		_on_cdan_cd_slider_value_changed.rpc(value,false)
	elif Global.mp_enabled and cdan_slider.value != int(value):
		cdan_cd_text.text = "Capital attacker protection duration: {0}".format([int(value)])
		Global.cdan_capture_duration = int(value)
		cdan_cd_slider.value = value
	else:
		cdan_cd_text.text = "Capital attacker protection duration: {0}".format([int(value)])
		Global.cdan_capture_duration = int(value)
	sound_play(true)

@rpc("any_peer")
func _on_blz_setting_toggled(toggled_on,mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		_on_blz_setting_toggled.rpc(toggled_on,false)
	blz_setting.button_pressed = toggled_on
	Global.blz_enabled = toggled_on
	sound_play()

@rpc("any_peer")
func _on_blz_slider_value_changed(value,mp_player_source=true):
	# Multiplayer parts.cdan_slider.value
	if Global.mp_enabled and mp_player_source and Global.blz_move_requrement != int(value):
		blz_text.text = "Bliz attack requirement: {0}".format([int(value)])
		Global.blz_move_requrement = int(value)
		_on_blz_slider_value_changed.rpc(value,false)
	elif Global.mp_enabled and blz_slider.value != int(value):
		blz_text.text = "Bliz attack requirement: {0}".format([int(value)])
		Global.blz_move_requrement = int(value)
		blz_slider.value = value
	else:
		blz_text.text = "Bliz attack requirement: {0}".format([int(value)])
		Global.blz_move_requrement = int(value)
	sound_play(true)

## Basic, this is just so I can mange ALL THE FLIPIN MOVEMENT SETTING IN ONE PLACE.[br]
## This, took so much time, and my hands hurt because of it. 
enum movement_edits {
	## Tile Initial limit
	ti_lim,
	## Tile Initial reduction
	ti_red,
	## Tile Second limit
	ts_lim,
	## Tile Second Reduction
	ts_red,
	## Fuel tile limit
	fl_lim,
	## Fuel tile reduction
	fl_red,
	## Turn moves limit
	tn_lim,
	## Turn moves reduction
	tn_red
}


#tile_int_lim_input.text = Global.moves_tile_int_lim_boost
#tile_int_reduct_input.text = Global.moves_tile_int_reduction_boost
#tile_sec_lim_input.text = Global.moves_tile_second_lim_boost
#tile_sec_reduct_input.text = Global.moves_tile_second_reduction_boost
#fuel_lim_input.text = Global.moves_fuel_lim_boost
#fuel_reduct_input.text = Global.moves_fuel_reduction_boost
#turn_lim_input.text = Global.moves_turn_lim_boost
#turn_reduct_input.text = Global.moves_turn_reduction_boost

## This funels the Movement setting into one place so I don't need to worry about a fuck ton of functions. Exuse my langage.[br][br]
## After it finds what its orign is, it sets its corisponding value. See [member menu_class.movement_edits]
@rpc("any_peer")
func _on_movement_setting_changed(new_text:String,origin:movement_edits,mp_player_source=true):
	if Global.mp_enabled and mp_player_source:
		_on_movement_setting_changed.rpc(new_text,origin,false)
	if new_text.is_valid_int():
		if new_text != str(new_text.to_int()):
			mp_player_source = false
			new_text = str(new_text.to_int())
		match origin:
			movement_edits.ti_lim:
				if not mp_player_source:
					tile_int_lim_input.text = new_text
				if new_text.to_int() < 0:
					new_text = "99999"
				Global.moves_tile_int_lim_boost = new_text.to_int()
			movement_edits.ti_red:
				if new_text.to_int() != 0:
					if not mp_player_source:
						tile_int_reduct_input.text = new_text
					Global.moves_tile_int_reduction_boost = new_text.to_int()
				else:
					_on_movement_setting_changed("1",origin,false)
			
			movement_edits.ts_lim:
				if not mp_player_source:
					tile_sec_lim_input.text = new_text
				if new_text.to_int() < 0:
					new_text = "99999"
				Global.moves_tile_second_lim_boost = new_text.to_int()
			movement_edits.ts_red:
				if new_text.to_int() != 0:
					if not mp_player_source:
						tile_sec_reduct_input.text = new_text
					Global.moves_tile_second_reduction_boost = new_text.to_int()
				else:
					_on_movement_setting_changed("1",origin,false)
			
			movement_edits.fl_lim:
				if not mp_player_source:
					fuel_lim_input.text = new_text
				if new_text.to_int() < 0:
					new_text = "99999"
				Global.moves_fuel_lim_boost = new_text.to_int()
			movement_edits.fl_red:
				if new_text.to_int() != 0:
					if not mp_player_source:
						fuel_reduct_input.text = new_text
					Global.moves_fuel_reduction_boost = new_text.to_int()
				else:
					_on_movement_setting_changed("1",origin,false)
			
			movement_edits.tn_lim:
				if not mp_player_source:
					turn_lim_input.text = new_text
				if new_text.to_int() < 0:
					new_text = "99999"
				Global.moves_turn_lim_boost = new_text.to_int()
			movement_edits.tn_red:
				if new_text.to_int() != 0:
					if not mp_player_source:
						turn_reduct_input.text = new_text
					Global.moves_turn_reduction_boost = new_text.to_int()
				else:
					_on_movement_setting_changed("1",origin,false)
		sound_play()
	else:
		_on_movement_setting_changed("0",origin,false)


@onready var extra_setting_animator = $Extra_options/extra_setting_animator

func _on_open_and_close_extra_settings_button_toggled(toggled_on):
	if toggled_on:
		extra_setting_animator.play("open_extra_settings")
	else:
		extra_setting_animator.play("close_extra_settings")
	mange_other_menus(1,toggled_on)

func _on_profile_loader_menu_opened(toggled_on):
	mange_other_menus(2,toggled_on)

func mange_other_menus(menu_id:int,toggled_on:bool):
	if menu_id == 1:
		profile_loader.visible = not toggled_on
	if menu_id == 2:
		extra_options.visible = not toggled_on

# PROFILE FUNCTIONS
## Loads a profile.
## Can be used to send game info to anyone joining.
@rpc("any_peer")
func load_profile_data(profile:Dictionary,refresh=true):
	# map type
	if profile.keys().has("map") and profile.map is int:
		Global.map_type = profile.map
		_on_map_setting_item_selected(profile.map,false,true)
	# Wall count
	if profile.keys().has("wall") and profile.wall is int:
		Global.wall_count = profile.wall
	# Fuel count
	if profile.keys().has("fuel") and profile.fuel is int:
		Global.fuel_count = profile.fuel
	# Cap count
	if profile.keys().has("cap"): #and profile.cap is Array[int]:
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
	
	if not Global.mp_enabled and refresh:
		_ready()

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
		# Claim set
		data["claim"] = Global.claim_list
		# music type
		data["mus"] = Global.music_type
	return data


func _on_profile_loader_profile_request_save():
	profile_loader.save_profile(save_profile_data(false))


func _on_profile_loader_profile_selected(data):
	load_profile_data(data)
	if Global.mp_enabled:
		load_profile_data.rpc(data)
