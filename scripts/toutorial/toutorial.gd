extends Control


enum requirements {
	none,
	movement,
	movement_no_move,
	next_turn
}



@export var toutorial_menu_list : Array[PanelContainer]
@export var toutorial_changes_list : Array[Dictionary]
var cur_requirement : requirements = requirements.none
@export var selected_toutorial : int = 0
var last_selected = 0
@export var claim_mangement : Array[ClaimData]



@onready var toutorial_grid = $BoxContainer/PanelContainer/toutorial_grid
@onready var moves_plate = %moves_plate
@onready var next_turn_button = %next_turn
@onready var animate_menu = $animate_menu

var moves_prior = 3
var moves = 3
var colour_last_active = 1
var colour_active = 1

func _ready():
	for i in toutorial_menu_list:
		i.visible = false
	toutorial_menu_list[selected_toutorial].visible = true
	change_menu()

func _process(_delta):
	if selected_toutorial != last_selected and selected_toutorial in range(toutorial_menu_list.size()):
		change_menu()
		last_selected = selected_toutorial
	elif not selected_toutorial in range(toutorial_menu_list.size()):
		selected_toutorial = last_selected


func change_menu():
	toutorial_menu_list[last_selected].visible = false
	toutorial_menu_list[selected_toutorial].visible = true
	if last_selected > selected_toutorial:
		check_efects(toutorial_changes_list[last_selected],true)
	else:
		check_efects(toutorial_changes_list[selected_toutorial])

enum value_name {
	highlight,place,show_moves,activate_player,kill_player,name_player,set_requirement,set_moves_number,set_move_colour,
	enable_next_turn,repeated_set
}
const value_shift_names = [
	"highlight","place","show_moves","activate_player","kill_player","name_player","set_requirement","set_moves_number","set_move_colour",
	"enable_next_turn","repeated_set"
]

func check_efects(changes:Dictionary,removal=false):
	# repeated_set
	if changes.keys().has(value_shift_names[value_name.repeated_set]): #and changes[value_shift_names[0]] is Array[Vector2]:
		check_efects(changes[value_shift_names[value_name.repeated_set]],removal)
	if removal:
		# highlight
		if changes.keys().has(value_shift_names[value_name.highlight]): #and changes[value_shift_names[0]] is Array[Vector2]:
			toutorial_grid.remove_highlight(changes[value_shift_names[value_name.highlight]][0])
		# place
		#if changes.keys().has(value_shift_names[value_name.place]): #and changes[value_shift_names[0]] is Array[Vector2]:
			#toutorial_grid.on_claim_tile(changes[value_shift_names[value_name.place]][0],0)
		# show_moves
		if changes.keys().has(value_shift_names[value_name.show_moves]) and changes[value_shift_names[value_name.show_moves]] is bool:
			animate_menu.play("hide_menu" if changes[value_shift_names[value_name.show_moves]] == true else "show_menu")
		# activate_player
		if changes.keys().has(value_shift_names[value_name.activate_player]):
			claim_mangement[changes[value_shift_names[value_name.activate_player]][0]].claim_active = not changes[value_shift_names[value_name.activate_player]][1]
		# set_requirement
		if changes.keys().has(value_shift_names[value_name.set_requirement]) and changes[value_shift_names[value_name.set_requirement]] is int:
			cur_requirement = requirements.none
		# set_moves_number
		if changes.keys().has(value_shift_names[value_name.set_moves_number]) and changes[value_shift_names[value_name.set_moves_number]] is int:
			moves = moves_prior
			moves_plate.number = moves
			moves_plate.animate_change(moves)
		# set_move_colour
		if changes.keys().has(value_shift_names[value_name.set_move_colour]) and changes[value_shift_names[value_name.set_move_colour]] is int:
			colour_active = colour_last_active
			moves_plate.colour = colour_active
			moves_plate.shift_colour(colour_active)
		# enable_next_turn
		if changes.keys().has(value_shift_names[value_name.enable_next_turn]) and changes[value_shift_names[value_name.enable_next_turn]] is bool:
			next_turn_button.disabled = not changes[value_shift_names[value_name.enable_next_turn]]
	
	else:
		# highlight
		if changes.keys().has(value_shift_names[value_name.highlight]):# and changes.highlight is Array[Vector2]:
			toutorial_grid.add_highlight(changes[value_shift_names[value_name.highlight]][0],changes[value_shift_names[value_name.highlight]][1].x,changes[value_shift_names[value_name.highlight]][1].y)
		# place
		if changes.keys().has(value_shift_names[value_name.place]):# and changes.highlight is Array[Vector2]:
			toutorial_grid.on_claim_tile(changes[value_shift_names[value_name.place]][0],changes[value_shift_names[value_name.place]][1].x,changes[value_shift_names[value_name.place]][1].y)
		# show_moves
		if changes.keys().has(value_shift_names[value_name.show_moves]) and changes[value_shift_names[value_name.show_moves]] is bool:
			animate_menu.play("show_menu" if changes[value_shift_names[value_name.show_moves]] == true else "hide_menu")
		# activate_player
		if changes.keys().has(value_shift_names[value_name.activate_player]):
			claim_mangement[changes[value_shift_names[value_name.activate_player]][0]].claim_active = changes[value_shift_names[value_name.activate_player]][1]
		# kill_player
		if changes.keys().has(value_shift_names[value_name.kill_player]):
			claim_mangement[changes[value_shift_names[value_name.kill_player]][0]].claim_dead = changes[value_shift_names[value_name.kill_player]][1]
		# name_player
		if changes.keys().has(value_shift_names[value_name.name_player]):
			claim_mangement[changes[value_shift_names[value_name.name_player]][0]].name = changes[value_shift_names[value_name.name_player]][1]
		# set_requirement
		if changes.keys().has(value_shift_names[value_name.set_requirement]) and changes[value_shift_names[value_name.set_requirement]] is int:
			cur_requirement = requirements[requirements.keys()[changes[value_shift_names[value_name.set_requirement]]]]
		else:
			cur_requirement = requirements.none
		# set_moves_number
		if changes.keys().has(value_shift_names[value_name.set_moves_number]) and changes[value_shift_names[value_name.set_moves_number]] is int:
			moves_prior = moves
			moves = changes[value_shift_names[value_name.set_moves_number]]
			moves_plate.number = moves
			moves_plate.animate_change(moves)
		# set_move_colour
		if changes.keys().has(value_shift_names[value_name.set_move_colour]) and changes[value_shift_names[value_name.set_move_colour]] is int:
			colour_last_active = colour_active
			colour_active = changes[value_shift_names[value_name.set_move_colour]]
			moves_plate.colour = colour_active
			moves_plate.shift_colour(colour_active)
		# enable_next_turn
		if changes.keys().has(value_shift_names[value_name.enable_next_turn]) and changes[value_shift_names[value_name.enable_next_turn]] is bool:
			next_turn_button.disabled = changes[value_shift_names[value_name.enable_next_turn]]
		


func next_menu_unlock(menu:int):
	toutorial_menu_list[menu].get_child(0).get_child(1).disabled = false


func _on_next_pressed():
	selected_toutorial += 1


func _on_before_pressed():
	selected_toutorial -= 1

# REQUREMENT EVENTS


func _on_toutorial_grid_took_tile(claim:int,type:int,moved=true):
	if cur_requirement == requirements.movement and moved or cur_requirement == requirements.movement_no_move:
		next_menu_unlock(selected_toutorial)
	if moves - 1 >= 0 and moved:
		moves -= 1
		moves_prior = moves
		moves_plate.number = moves
		moves_plate.animate_change(moves)
		var claim_pos = 0
		for i in range(claim_mangement.size()):
			claim_pos = i if claim_mangement[i].claim_colour == claim else claim_pos
		if type == 0:
			claim_mangement[claim_pos].tile_size += 1
		if type == 2:
			claim_mangement[claim_pos].tile_size += 1
			claim_mangement[claim_pos].fuel_count += 1
		
	else:
		moves_plate.number = moves
		moves_plate.animate_change(moves)


func _on_next_turn_pressed():
	if cur_requirement == requirements.next_turn:
		_on_next_pressed()
		next_turn_button.disabled = true
