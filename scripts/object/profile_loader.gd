extends Control

var profile_path = "./profiles"
var profile_folder
var defualt_profile_path = "res://Resources/profiles"

func _ready():
	profile_folder = DirAccess.open(profile_path)
	
