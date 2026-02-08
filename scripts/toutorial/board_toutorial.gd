extends PanelContainer

signal took_tile(claim:int,type:int)

@onready var base_scene = $"../../.."


@onready var main_grid = $main_grid
@onready var overlay_grid = $overlay_grid
@onready var action_grid = $action_grid
## The grid_coords where the mouse is.
var grid_coords : Vector2i
## For game sounds. (CURRENTLY USING SOUNDS FROM GOD MACHINE)
var sound : AudioStreamPlayer
## Watches for if the mouse is on the board or not.
var hovered = false
## makes it so it cant be used.
var lock_mode = false

var off_input = false

 
func _ready():
	sound = AudioStreamPlayer.new()
	add_child(sound)
	sound.volume_db = linear_to_db(Global.SFX_vol/10)

func _process(_delta):
	if hovered:
		# Get mouse position on grid.
		var mouse_pos = get_global_mouse_position()
		overlay_grid.clear()
		grid_coords = overlay_grid.local_to_map(overlay_grid.to_local(mouse_pos))
		
		# See if tile is claimable
		lock_mode = not check_tile_claimably(grid_coords,1) #mp replace 1 with game.active_player.claim_colour
		
		# Set the overlay
		var type = 2 if lock_mode or off_input else 0
		if lock_mode:
			overlay_grid.modulate = Color(1.0, 1.0, 1.0, 0.627)
		else:
			overlay_grid.modulate = Color(0.5, 0.5, 0.5, 0.255)
		overlay_grid.set_cell(grid_coords, 0, Vector2i(1,type))

## Gets if the mouse enters the board. [member board.hovered]
func _on_mouse_entered():
	hovered = true

## Gets if the mouse leaves the board. [member board.hovered]
func _on_mouse_exited():
	hovered = false

## Fires for any click on the board.
func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and not (lock_mode or off_input):
			on_claim_tile(grid_coords,1) #mp replace 1 with game.active_player.claim_colour
			remove_highlight(grid_coords)
			sound.stream = load("res://audio/FX/left click sound.mp3") as AudioStream
		else:
			took_tile.emit(0,0,false)
			sound.stream = load("res://audio/FX/right click sound.mp3") as AudioStream
		sound.play()


## Sets a tile on the main board.
func on_claim_tile(coords,claim:int,type:int=-1,no_emition=false):
	var picked_tile : TileData = main_grid.get_cell_tile_data(coords)
	if picked_tile != null:
		var changed = true
		if picked_tile.get_custom_data("type") == 1 and type == -1:
			type = 1
		elif picked_tile.get_custom_data("type") == 2 and type in [1,3]:
			type = 2
			changed = false
		elif picked_tile.get_custom_data("type") == 3 and type == -1:
			type = 3
		elif type == -1:
			type = 0
		main_grid.set_cell(coords,0,Vector2i(claim,type))
		if not no_emition:
			took_tile.emit(claim,type)
		if (picked_tile.get_custom_data("type") == 1 or (type == 1 or type == 2) and not picked_tile.get_custom_data("type") == 1) and changed:
			if type != 2:
				type = 0
			var neighbors = main_grid.get_surrounding_cells(coords)
			for neighbor in neighbors:
				picked_tile = main_grid.get_cell_tile_data(neighbor)
				if not picked_tile == null:
					on_claim_tile(neighbor,claim,type)

func check_tile_claimably(coords,claim):
	var picked_tile : TileData = action_grid.get_cell_tile_data(coords)
	if picked_tile != null:
		if picked_tile.get_custom_data("ownership") != claim:
			return false
		if base_scene.moves == 0:
			return false
		return true
	return false

func add_highlight(coords,claim,type):
	var picked_tile : TileData = main_grid.get_cell_tile_data(coords)
	if picked_tile.get_custom_data("ownership") == claim and picked_tile.get_custom_data("type") == type:
		return
	action_grid.set_cell(coords,0,Vector2(claim,type))

func remove_highlight(coords):
	action_grid.erase_cell(coords)
