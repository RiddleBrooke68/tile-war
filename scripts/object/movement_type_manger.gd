extends Control

enum modes {
	claim_tile,
	blitz_tile
}

var mode = modes.claim_tile

@onready var claim = $PanelContainer/claim
@onready var blitz = $PanelContainer/blitz

func _ready():
	if not Global.blz_enabled:
		blitz.disabled = true
		blitz.visible = false
	else:
		blitz.disabled = false
		blitz.visible = true
	swich_mode(mode)


func swich_mode(_mode):
	if _mode == modes.claim_tile:
		mode = modes.claim_tile
		claim.button_pressed = true
		blitz.button_pressed = false
	elif _mode == modes.blitz_tile:
		mode = modes.blitz_tile
		blitz.button_pressed = true
		claim.button_pressed = false
