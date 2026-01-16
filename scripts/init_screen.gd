extends Control

var cmd_args = {}

var screen = 0

func _ready():
	for cmdline in OS.get_cmdline_args():
			if cmdline.contains("="):
				var key_value = cmdline.split("=")
				cmd_args[key_value[0].trim_prefix("--")] = key_value[1]
			else:
				# Options without an argument will be present in the dictionary,
				# with the value set to an empty string.
				cmd_args[cmdline.trim_prefix("--")] = ""
	
	if "mp_start_server" in cmd_args.keys():
		screen = 1
	elif "brc_testing" in cmd_args.keys():
		screen = 2

func _process(_delta):
	if screen == 0:
		get_tree().change_scene_to_file("res://levels/menu.tscn")
	elif screen == 1:
		get_tree().change_scene_to_file("res://levels/menu_mp.tscn")
	elif screen == 2:
		get_tree().change_scene_to_file("res://webrtc_toutorial/brc_testing.tscn")
