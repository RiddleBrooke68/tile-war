extends Control

var cmd_args = {}

var screen = 0

func _ready():
	#for cmdline in OS.get_cmdline_args():
			#if cmdline.contains("="):
				#var key_value = cmdline.split("=")
				#cmd_args[key_value[0].trim_prefix("--")] = key_value[1]
			#else:
				# Options without an argument will be present in the dictionary,
				# with the value set to an empty string.
				#cmd_args[cmdline.trim_prefix("--")] = ""
	if Global.cmd_args.keys().any(func(num): return num in ["help_tw","h"]):
		print("\n-------------------------------\n")
		print_rich("[b]Commands:[/b] Color key\n")
		print_rich("[color=green]Green:[/color] Means it sets what screen you will open up on. ")
		print_rich("[color=red]Red:[/color] Means it sets the games setting on start up. ")
		print_rich("[color=yellow]Yellow:[/color] Means it a expermental command and is not for gameplay. ")
		print("\n-------------------------------\n")
		print_rich("[b]Commands:[/b] Game Settings\n")
		
		print("\n-------------------------------\n")
		print_rich("[b]Commands:[/b] Scenes\n")
		print_rich("[color=green]--mp --multiplayer:[/color] Starts up on the multiplayer.")
		print_rich("[color=green]--brc_[/color][color=yellow]testing:[/color] Opens the broadcast test screen. The early stages of multiplayer online. DOES NOT WORK.")
		print("\n-------------------------------\n")
		print_rich("[b]Commands:[/b] Dedicating\n")
		print_rich("[color=green]--mp_[/color][color=red]start_server:[/color] Starts up on the multiplayer and starts a lan server.")
		print_rich("[color=green]--dedicated:[/color] Starts a headless dedicated server. Clients connect via IP:port.")
		print_rich("[color=red]--port=N:[/color] Sets the dedicated server port (default 7777). Range: 1024-65535.")
		print_rich("[color=red]--server_name=X:[/color] Sets the dedicated server display name.")
		print_rich("[color=red]--brc_[/color][color=yellow]dedicate:[/color] starts up a testing brc dedicated server. ")
		get_tree().quit()
	
	# Starts a dedicated headless server
	if "dedicated" in Global.cmd_args.keys():
		screen = 1
	# Starts a server
	elif "mp_start_server" in Global.cmd_args.keys():
		screen = 1
	# Auto open local multiplayer
	elif Global.cmd_args.keys().any(func(num): return num in ["multiplayer","mp"]):
		screen = 1
	# For broadcast testing only
	if "brc_testing" in Global.cmd_args.keys():
		screen = 2

func _process(_delta):
	if screen == 0:
		get_tree().change_scene_to_file("res://levels/menu.tscn")
	elif screen == 1:
		get_tree().change_scene_to_file("res://levels/menu_mp.tscn")
	elif screen == 2:
		get_tree().change_scene_to_file("res://webrtc_toutorial/brc_testing.tscn")
