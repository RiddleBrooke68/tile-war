extends Control

@onready var start_game = $BoxContainer/start_game

@onready var map_setting = $BoxContainer/map/map_setting

@onready var wall_text = $BoxContainer/GridContainer/wall_settings/Label
@onready var wall_slider = $BoxContainer/GridContainer/wall_settings/WallSlider
@onready var fuel_text = $BoxContainer/GridContainer/fuel_settings/Label
@onready var fuel_slider = $BoxContainer/GridContainer/fuel_settings/FuelSlider
@onready var ai_level = $BoxContainer/BoxContainer/ai_level_setting

# Claims and their control.
@onready var green_claim_type = %green_claim_type
@onready var purple_claim_type = %purple_claim_type
@onready var yellow_claim_type = %yellow_claim_type
@onready var red_claim_type = %red_claim_type

@onready var green_name = %green_name
@onready var purple_name = %purple_name
@onready var yellow_name = %yellow_name
@onready var red_name = %red_name


##@deprecated
@onready var player_setting = $BoxContainer/GridContainer/player_setting
##@deprecated
@onready var purple_setting = $BoxContainer/GridContainer/purple_setting
##@deprecated
@onready var yellow_setting = $BoxContainer/GridContainer/yellow_setting
##@deprecated
@onready var red_setting = $BoxContainer/GridContainer/red_setting

@onready var player_cap = %player_cap
@onready var plum_cap = %plum_cap
@onready var york_cap = %york_cap
@onready var river_cap = %river_cap
@onready var cap_list = [player_cap,plum_cap,york_cap,river_cap]

@onready var lms_setting = $BoxContainer/BoxContainer2/lms_setting

@onready var music_type = $"BoxContainer3/BoxContainer/Music type/music_type_setting"
@onready var music_slider = $BoxContainer3/BoxContainer/music_settings/MusicSlider
@onready var sfx_slider = $BoxContainer3/BoxContainer/sfx_settings/SfxSlider



## For game sounds. (CURRENTLY USING SOUNDS FROM GOD MACHINE)
var sound : AudioStreamPlayer

func _ready():
	sound = AudioStreamPlayer.new()
	add_child(sound)
	sound_play()
	# Pregenration
	map_setting.selected = Global.map_type
	_on_map_setting_item_selected(map_setting.selected)
	# Genration
	wall_slider.value = Global.wall_count
	_on_wall_slider_value_changed(wall_slider.value)
	fuel_slider.value = Global.fuel_count
	_on_fuel_slider_value_changed(fuel_slider.value)
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
	# Music
	music_type.selected = Global.music_type
	music_slider.value = Global.music_vol
	sfx_slider.value = Global.SFX_vol

func sound_play(use_drag=false):
	if not use_drag or drag:
		sound.volume_linear = Global.SFX_vol/10
		sound.stream = load("res://audio/FX/left click sound.mp3") as AudioStream
		sound.play()


var drag = false

func drag_ended(value):
	drag = value

func _on_map_setting_item_selected(index):
	Global.map_type = index
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

func _on_wall_slider_value_changed(value):
	wall_text.text = "Wall count: {0}".format([value])
	Global.wall_count = value
	sound_play(true)

func _on_fuel_slider_value_changed(value):
	fuel_text.text = "Fuel count: {0}".format([value])
	Global.fuel_count = value
	sound_play(true)


# Indviual Claim Settings

# Names everyyyyBODY!!!

func _on_green_name_text_submitted(new_text):
	Global.claim_names[0] = new_text


func _on_purple_name_text_submitted(new_text):
	Global.claim_names[1] = new_text


func _on_yellow_name_text_submitted(new_text):
	Global.claim_names[2] = new_text


func _on_red_name_text_submitted(new_text):
	Global.claim_names[3] = new_text

# Who is who
#mp I would probably use a new set of option buttons.
#mp Ooh, and thats a thought, adding a name plate, so if you are playing as someone, you can use a custom name.

func _on_green_claim_type_item_selected(index):
	Global.claim_list[0] = index
	

func _on_purple_claim_type_item_selected(index):
	Global.claim_list[1] = index

func _on_yellow_claim_type_item_selected(index):
	Global.claim_list[2] = index

func _on_red_claim_type_item_selected(index):
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


func _on_player_cap_item_selected(index):
	Global.cap_list[0] = index + 1
	sound_play()


func _on_plum_cap_item_selected(index):
	Global.cap_list[1] = index + 1
	sound_play()


func _on_york_cap_item_selected(index):
	Global.cap_list[2] = index + 1
	sound_play()



func _on_river_cap_item_selected(index):
	Global.cap_list[3] = index + 1
	sound_play()


func _on_start_game():
	get_tree().change_scene_to_file("res://levels/main_ui.tscn")


func _on_change_ai_level(index):
	Global.ai_level = index
	sound_play()


func _on_lms_setting_toggled(toggled_on):
	Global.lms_enabled = toggled_on
	sound_play()


func _on_music_type_setting_item_selected(index):
	Global.music_type = index
	sound_play()


func _on_music_slider_value_changed(value):
	Global.music_vol = value
	sound_play(true)



## Sets the volume of sound efects
func _on_sfx_slider_value_changed(value):
	Global.SFX_vol = value
	sound_play(true)
