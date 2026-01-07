extends BoxContainer

@onready var nameplate = %name

func set_nameplate(newname:String,newcolour=Color(1.0, 1.0, 1.0, 1.0)):
	var newcolour_hex = newcolour.to_html()
	nameplate.text = "[color={1}]{0}[/color]".format([newname,newcolour_hex])
