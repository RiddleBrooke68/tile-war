extends Node

const mod_path = "./mods"
const music_path = "/audio"
var mod_paths_list = []
var mod_folder : DirAccess

func _ready():
	get_mods_paths()

func get_mods_paths(path=mod_path):
	var file_name
	mod_paths_list = []
	mod_folder = DirAccess.open(path)
	
	if mod_folder:
		mod_folder.list_dir_begin()
		file_name = mod_folder.get_next()
		while file_name != "":
			if mod_folder.current_is_dir():
				print("Found directory: " + file_name)
				get_mods_paths(mod_folder.get_current_dir()+"/"+file_name)
			else:
				print("Found file: " + file_name)
				mod_paths_list.append(mod_folder.get_current_dir()+"/"+file_name)
			file_name = mod_folder.get_next()
	else:
		print("An error occurred when trying to access the path.")
		DirAccess.make_dir_absolute(mod_path)

## If a path contains any of these extra points, the file is ignored.
const disable_list = [".disabled",".break",".remove",".no",".none"]
func get_mods_list(wants:int):
	for path in mod_paths_list:
		var result = false
		for i in disable_list:
			if path.contains(i):
				result = true
		
		if not result:
			if path.contains("/audio") and wants in [0,1]:
				if path.contains("main.ogg") and wants == 0:
					return path
	return ""
