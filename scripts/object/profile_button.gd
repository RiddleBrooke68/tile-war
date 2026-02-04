extends BoxContainer

signal profile_selected(data:profile_data)
signal profile_deleted(path:String)

@onready var profile_name : Button = %profile_name
@onready var profile_discription : RichTextLabel= %profile_discription
@onready var profile_type : Label = %profile_type
@onready var profile_delete_button = %profile_delete_button

@export var profile : profile_data

func _ready():
	profile_name.text = profile.profile_name
	profile_discription.text = profile.profile_discription
	profile_type.text = "Interal file" if profile.profile_type == 1 else "External File"
	profile_delete_button.visible = false if profile.profile_type == 1 else true

func on_profile_selected():
	profile_selected.emit(profile)


func _on_profile_delete():
	if profile.profile_path != "":
		profile_deleted.emit(profile.profile_path)
