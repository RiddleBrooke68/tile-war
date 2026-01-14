
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

func _ready(mp_is_updating=false):
	sound = AudioStreamPlayer.new()
	add_child(sound)
	sound_play()
	# Pregenration
	map_setting.selected = Global.map_type
	_on_map_setting_item_selected(map_setting.selected,true,false)
	# Genration
	wall_slider.value = Global.wall_count
	_on_wall_slider_value_changed(wall_slider.value)
	fuel_slider.value = Global.fuel_count
	_on_fuel_slider_value_changed(fuel_slider.value)
	cdan_slider.value = Global.cdan_duration
	_on_cdan_slider_value_changed(cdan_slider.value)
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
		Global.mp_player_list = {}


func sound_play(use_drag=false):
	if not use_drag or drag:
		sound.volume_linear = Global.SFX_vol/10
		sound.stream = load("res://audio/FX/left click sound.mp3") as AudioStream
		sound.play()


var drag = false

func drag_ended(value):
	drag = value

@rpc("any_peer")
func _on_map_setting_item_selected(index,mp_player_source=true,block=false):
	if Global.mp_enabled and mp_player_source:
		_on_map_setting_item_selected.rpc(index,false)
	map_setting.selected = index
	Global.map_type = index
	if not block:
		for i in range(0,4):
			if index == 0:
				cap_list[i].selected = 0
				Global.cap_list[i] = 1
				cap_list[i].set_item_disabled(1,false)
				cap_list[i].set_item_disabled(2,false)
				cap_list[i].set_item_disabled(3,true)
			elif index == 1:
				cap_list[i].selected = 1
				Global.cap_list[i] = 2
				cap_list[i].set_item_disabled(1,false)
				cap_list[i].set_item_disabled(2,false)
				cap_list[i].set_item_disabled(3,false)
			elif index == 2:
				cap_list[i].selected = 1
				Global.cap_list[i] = 2
				cap_list[i].set_item_disabled(1,false)
				cap_list[i].set_item_disabled(2,true)
				cap_list[i].set_item_disabled(3,true)
			elif index == 3:
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
		_on_change_ai_level.rpc(index,false)
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
