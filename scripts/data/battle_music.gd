extends Resource
class_name battle_music_data

@export var music_name = ""

@export var track_base : AudioStream
@export var track_greenwich : AudioStream
@export var track_plum : AudioStream
@export var track_york : AudioStream
@export var track_river : AudioStream
@export var track_builders : AudioStream

enum track_types {
	base, green, purple, yellow, red, blue
}

var track_set = []

func give_track(i:track_types):
	track_set = [track_base,track_greenwich,track_plum,track_york,track_river,track_builders]
	if track_set[i] != null:
		return track_set[i]
	return AudioStream.new()
