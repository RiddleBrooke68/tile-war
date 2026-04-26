## This is so dumb, but this is how I am setting up.
extends Node2D

@export_file("*.tres") var map_path = ""
@onready var main_grid : TileMapLayer = $main_grid

func _ready():
	var file = load(map_path) as map_data
	
	if file.map_patern == null:
		file.map_patern = main_grid.tile_set.get_pattern(1)
		
		var err = ResourceSaver.save(file)
		if err != OK:
			print("Err")
			return
	
	main_grid.set_pattern(file.map_centre,file.map_patern)
