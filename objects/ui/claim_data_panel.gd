extends Control

@onready var panel = $panel
@onready var claim_name = $name
@onready var claim_tiles = $tiles
@onready var claim_fuel = $fuel
@onready var claim_capitals = $capitals


@export var claim : ClaimData
	#set(c):
		#claim = c
		#update()
## The panel will use this if the claim is dead.
@export var dead_panel :  Texture
## If a panel cannot be asined, then use this.
@export var fallback_panel : Texture

func _ready():
	update()
	claim.connect("changed_info",update)

func update():
	if claim != null:
		claim_name.text = claim.name
		claim_tiles.text = str(claim.tile_size)
		claim_fuel.text = str(claim.fuel_count)
		claim_capitals.text = str(claim.capatal_tile.size())
		if not claim.claim_dead and claim.claim_panel != null:
			panel.texture = claim.claim_panel
		elif claim.claim_dead and dead_panel != null:
			panel.texture = dead_panel
		else:
			panel.texture = fallback_panel
