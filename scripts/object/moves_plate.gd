@tool
extends Node2D

@onready var plate_back = $plate_back
@onready var plate_number = $plate_number
@onready var plate_front = $plate_front

@export var number_set : Array[CompressedTexture2D] = [
	preload("res://sprites/ui/moves/numbers/0-9/move_0.png") as CompressedTexture2D,
	preload("res://sprites/ui/moves/numbers/0-9/move_1.png") as CompressedTexture2D,
	preload("res://sprites/ui/moves/numbers/0-9/move_2.png") as CompressedTexture2D,
	preload("res://sprites/ui/moves/numbers/0-9/move_3.png") as CompressedTexture2D,
	preload("res://sprites/ui/moves/numbers/0-9/move_4.png") as CompressedTexture2D,
	preload("res://sprites/ui/moves/numbers/0-9/move_5.png") as CompressedTexture2D,
	preload("res://sprites/ui/moves/numbers/0-9/move_6.png") as CompressedTexture2D,
	preload("res://sprites/ui/moves/numbers/0-9/move_7.png") as CompressedTexture2D,
	preload("res://sprites/ui/moves/numbers/0-9/move_8.png") as CompressedTexture2D,
	preload("res://sprites/ui/moves/numbers/0-9/move_9.png") as CompressedTexture2D,
]
@export var overflow_num : CompressedTexture2D = preload("res://sprites/ui/moves/numbers/move_overflow.png") as CompressedTexture2D

@export var number = 10:
	set(num):
		animate_change(num)
		number = num

## @deprecated
func set_plate_number(num:int):
	if num < number_set.size() and 0 <= num:
		plate_number.texture = number_set[num]
	else:
		plate_number.texture = overflow_num
	pass

func update_plate_display():
	if number < number_set.size() and 0 <= number:
		plate_number.texture = number_set[number]
	else:
		plate_number.texture = overflow_num
	pass

@onready var animation_player = $AnimationPlayer

func animate_change(num):
	if animation_player.is_playing():
		update_plate_display()
	animation_player.play("RESET")
	if number == num or number == 0:
		animation_player.play("out_of_moves")
		update_plate_display()
	elif number != num:
		animation_player.play("drop_move")
