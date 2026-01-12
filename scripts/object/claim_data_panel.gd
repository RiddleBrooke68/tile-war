extends Control
class_name ClaimDataPanel

@onready var panel = $panel
@onready var claim_name = $panel/name
@onready var claim_tiles = $panel/tiles
@onready var claim_fuel = $panel/fuel
@onready var claim_capitals = $panel/capitals
@onready var active_indcator = $active_indcator

## This is what the panel will be reading.
@export var claim : ClaimData:
	set(c):
		if claim != null and claim != c:
			claim.disconnect("changed_info",update)
			claim = c
			claim.connect("changed_info",update)
		else:
			claim = c
## The panel will use this if the claim is dead.
@export var dead_panel :  Texture
## If a panel cannot be asined, then use this.
@export var fallback_panel : Texture

var active_turn = false

func _ready():
	update()
	claim.connect("changed_info",update)

func update():
	if claim != null:
		claim_name.text = claim.name
		claim_tiles.text = str(claim.tile_size)
		claim_fuel.text = str(claim.fuel_count)
		claim_capitals.text = str(claim.capatal_tile.size())
		if not claim.claim_dead and claim.claim_panel_normal != null:
			panel.texture = claim.claim_panel_normal
		elif claim.claim_dead and dead_panel != null:
			panel.texture = dead_panel
		else:
			panel.texture = fallback_panel
		# Animate if is having or just had their turn.
		if claim.claim_active and not active_turn:
			active_indcator.play("start_turn")
		if  active_turn and not claim.claim_active:
			active_indcator.play("end_turn")
		active_turn = claim.claim_active
