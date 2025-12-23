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


func _ready():
	wall_slider.value = Global.wall_count
	fuel_slider.value = Global.fuel_count
	ai_level.selected = Global.ai_level
	for i in range(0,4):
		cap_list[i].selected = Global.cap_list[i] - 1

func _on_wall_slider_value_changed(value):
	wall_text.text = "Wall count: {0}".format([value])
	Global.wall_count = value

func _on_fuel_slider_value_changed(value):
	fuel_text.text = "Fuel count: {0}".format([value])
	Global.fuel_count = value

# Enabled claims
func _on_player_setting_toggled(toggled_on):
	Global.player_enabled = toggled_on


func _on_purple_setting_toggled(toggled_on):
	Global.purple_enabled = toggled_on


func _on_yellow_setting_toggled(toggled_on):
	Global.yellow_enabled = toggled_on


func _on_red_setting_toggled(toggled_on):
	Global.red_enabled = toggled_on


func _on_player_cap_item_selected(index):
	Global.cap_list[0] = index + 1


func _on_plum_cap_item_selected(index):
	Global.cap_list[1] = index + 1


func _on_york_cap_item_selected(index):
	Global.cap_list[2] = index + 1



func _on_river_cap_item_selected(index):
	Global.cap_list[3] = index + 1


func _on_start_game():
	get_tree().change_scene_to_file("res://levels/main_ui.tscn")


func _on_change_ai_level(index):
	Global.ai_level = index
