@tool
extends Node2D

@onready var plate_back = $plate_back
@onready var plate_number = $plate_number
@onready var plate_moves = $plate_moves
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

@export var move_title_colours : Array[CompressedTexture2D] = [
	preload("res://sprites/ui/moves/player_indicator/move_green_indacator.png") as CompressedTexture2D,
	preload("res://sprites/ui/moves/player_indicator/move_purple_indacator.png") as CompressedTexture2D,
	preload("res://sprites/ui/moves/player_indicator/move_yellow_indacator.png") as CompressedTexture2D,
	preload("res://sprites/ui/moves/player_indicator/move_red_indacator.png") as CompressedTexture2D,
]
@export var move_title_unknown_colour : CompressedTexture2D = preload("res://sprites/ui/moves/player_indicator/move_unknown_indacator.png") as CompressedTexture2D
@export var colour = 0:
	set(index):
		shift_colour(index)
		colour = index

## @deprecated
func set_plate_number(num:int):
	if num < number_set.size() and 0 <= num:
		plate_number.texture = number_set[num]
	else:
		plate_number.texture = overflow_num
	pass

func update_plate_display(type=0):
	if type == 0:
		if number < number_set.size() and 0 <= number:
			plate_number.texture = number_set[number]
		else:
			plate_number.texture = overflow_num
	elif type == 1:
		if colour in range(1,move_title_colours.size()+1):
			plate_moves.texture = move_title_colours[colour-1]
		else:
			plate_moves.texture = move_title_unknown_colour
	pass

@onready var number_shifter = $number_shifter

func animate_change(num):
	if number_shifter == null:
		return
	if number_shifter.is_playing():
		update_plate_display()
	number_shifter.play("RESET")
	if number == num or number == 0:
		number_shifter.play("out_of_moves")
		update_plate_display()
	elif number != num:
		number_shifter.play("drop_move")

@onready var move_shifter = $move_shifter

func shift_colour(index):
	if move_shifter.is_playing():
		update_plate_display(1)
	move_shifter.play("RESET")
	if colour == index:
		move_shifter.play("RESET")
		update_plate_display(1)
	elif colour != index:
		move_shifter.play("change_claim")
