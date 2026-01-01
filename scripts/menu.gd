extends Control

@onready var start_game = $BoxContainer/start_game

@onready var wall_text = $BoxContainer/GridContainer/wall_settings/Label
@onready var wall_slider = $BoxContainer/GridContainer/wall_settings/WallSlider
@onready var fuel_text = $BoxContainer/GridContainer/fuel_settings/Label
@onready var fuel_slider = $BoxContainer/GridContainer/fuel_settings/FuelSlider
@onready var ai_level = $BoxContainer/BoxContainer/ai_level_setting

@onready var player_setting = $BoxContainer/GridContainer/player_setting
@onready var purple_setting = $BoxContainer/GridContainer/purple_setting
@onready var yellow_setting = $BoxContainer/GridContainer/yellow_setting
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
	# Genration
	wall_slider.value = Global.wall_count
	_on_wall_slider_value_changed(wall_slider.value)
	fuel_slider.value = Global.fuel_count
	_on_fuel_slider_value_changed(fuel_slider.value)
	# Ai
	ai_level.selected = Global.ai_level
	# Active players
	player_setting.button_pressed 	= Global.player_enabled
	purple_setting.button_pressed 	= Global.purple_enabled
	yellow_setting.button_pressed 	= Global.yellow_enabled
	red_setting.button_pressed  	= Global.red_enabled
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

func _on_wall_slider_value_changed(value):
	wall_text.text = "Wall count: {0}".format([value])
	Global.wall_count = value
	sound_play(true)

func _on_fuel_slider_value_changed(value):
	fuel_text.text = "Fuel count: {0}".format([value])
	Global.fuel_count = value
	sound_play(true)

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
