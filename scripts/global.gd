extends Node

var wall_count = 74
var fuel_count = 25
var player_enabled = true
var purple_enabled = true
var yellow_enabled = true
var red_enabled = true
var ai_level = 1:
	set(value):
		if value == 1:
			dist = 2
		elif value == 2:
			dist = 3
		ai_level =  value
var dist = 2
var cap_list = [1,1,1,1]
var lms_enabled = true
