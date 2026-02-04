extends Panel

signal profile_selected(data:Dictionary)
signal profile_request_save()
signal menu_opened(toggled_on:bool)

@onready var profile_browser = %profile_browser
@onready var profile_name = %profile_name
@onready var profile_discription = %profile_discription
@onready var profile_saver = %profile_saver


@export var profile_obj : PackedScene

var profile_path = "./profiles"
var defualt_profile_path = "res://Resources/profiles"
var profile_folder
var profile_path_list = []
var profile_access : FileAccess
var profile_init : Dictionary
var profile : profile_data
var profile_list : Array[profile_data]

func _ready():
	refresh_menu()

func refresh_menu():
	get_profile_paths()
	get_profile_list()
	
	for i in get_tree().get_nodes_in_group("profile_panel"):
		i.free()
	for pro in range(profile_list.size()):
		var profile_panel = profile_obj.instantiate()
		profile_panel.profile = profile_list[pro]
		profile_browser.add_child(profile_panel)
		profile_panel.profile_selected.connect(set_profile)
		profile_panel.profile_deleted.connect(profile_deleted)
	profile_list.clear()

func get_profile_paths():
	var file_name
	profile_path_list = []
	profile_folder = DirAccess.open(profile_path)
	
	if profile_folder:
		profile_folder.list_dir_begin()
		file_name = profile_folder.get_next()
		while file_name != "":
			if profile_folder.current_is_dir():
				print("Found directory: " + file_name)
			else:
				print("Found file: " + file_name)
				profile_path_list.append(profile_folder.get_current_dir()+"/"+file_name)
			file_name = profile_folder.get_next()
	else:
		print("An error occurred when trying to access the path.")
		DirAccess.make_dir_absolute(profile_path)
	
	profile_folder = DirAccess.open(defualt_profile_path)
	
	profile_folder.list_dir_begin()
	file_name = profile_folder.get_next()
	while file_name != "":
		if profile_folder.current_is_dir():
			pass #print("Found directory: " + file_name)
		else:
			pass #print("Found file: " + file_name)
			profile_path_list.append(profile_folder.get_current_dir()+"/"+file_name)
		file_name = profile_folder.get_next()

func get_profile_list():
	for path in profile_path_list:
		#print("path: ",path)
		if path.contains(".tres"):
			if path.contains(".remap"):
				path = path.replace(".remap","")
			profile = load(path) as profile_data#ResourceLoader.load(path).duplicate(true)
			profile.profile_type = 1
		elif path.ends_with(".json"):
			profile_access = FileAccess.open(path,FileAccess.READ)
			profile_init = JSON.parse_string(profile_access.get_as_text())
			#print("Json ",profile_init)
			if (
					(profile_init.keys().has("name") and profile_init.keys().has("discription") and profile_init.keys().has("settings") and profile_init.keys().has("path"))
					and 
					(profile_init.name is String and profile_init.discription is String and profile_init.settings is Dictionary and profile_init.path is String)):
				
				profile = profile_data.new()
				profile.profile_name = profile_init.name
				profile.profile_path = profile_init.path
				profile.profile_discription = profile_init.discription
				profile.settings = profile_init.settings
			profile_access.close()
			profile_access = null
			profile_init = {}
		if profile is profile_data:
			profile_list.append(profile)
			profile = null

func set_profile(data:profile_data):
	for i in data.settings.keys():
		if data.settings[i] is float:
			data.settings[i] = int(data.settings[i])
		elif data.settings[i] is Array[float]:
			for x in range(data.settings[i].size()):
				data.settings[i][x] = int(data.settings[i][x])
		elif data.settings[i] is Dictionary[String,float]:
			for x in data.settings[i].keys():
				data.settings[i][x] = int(data.settings[i][x])
	profile_selected.emit(data.settings)

func profile_deleted(path:String):
	DirAccess.remove_absolute(path)
	$Timer.start()
	#refresh_menu()

func save_profile(data:Dictionary):
	profile_init.settings = data
	profile_init.name = profile_name.text
	profile_init.path = "{0}/{1}.json".format([profile_path,profile_init.name])
	profile_init.discription = profile_discription.text
	var profile_temp = JSON.stringify(profile_init,"\t")
	profile_access = FileAccess.open("{0}/{1}.json".format([profile_path,profile_init.name]),FileAccess.WRITE)
	profile_access.store_string(profile_temp)
	profile_access.close()
	profile_access = null
	profile_init = {}
	refresh_menu()



func _on_profile_saver_pressed():
	profile_request_save.emit()



func _on_profile_name_text_changed(new_text):
	if new_text != "":
		profile_saver.disabled = false
	else:
		profile_saver.disabled = true

@onready var animation_player = $AnimationPlayer

func _on_animate_toggled(toggled_on):
	if toggled_on:
		animation_player.play("open")
	else:
		animation_player.play("close")
	menu_opened.emit(toggled_on)
