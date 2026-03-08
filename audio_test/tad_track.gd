extends Resource
class_name tad_track

enum track_types {
	base, green, purple, yellow, red, blue
}

@export var track_type : track_types
@export var audio_track : AudioStream
