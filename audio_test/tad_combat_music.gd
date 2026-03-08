 
extends Control

@export var music : tad_Combat_music

enum track_types {
	base, green, purple, yellow, red, blue
}

var music_tracks = {
	track_types.base:null,
	track_types.green:null,
	track_types.purple:null,
	track_types.yellow:null,
	track_types.red:null,
	track_types.blue:null
}

var active = 1

func _ready():
	for i in range(music.tracks.size()):
		var x = AudioStreamPlayer.new()
		music.tracks[i].audio_track.loop = true
		x.stream = music.tracks[i].audio_track
		add_child(x)
		music_tracks[music.tracks[i].track_type] = x
	for i in track_types:
		play_track(track_types[i])
		if track_types[i] > 0:
			change_track_volume(track_types[i],0)

func repeat_checks():
	for i in music_tracks.keys():
		change_track_volume(i, Global.music_vol/10.0/5.0 if not i in [active,0] else Global.music_vol/10.0, 8.0 if not i in [active,0] else 2.0)

func play_track(track_type:track_types):
	var x = music_tracks[track_type]
	if x is AudioStreamPlayer:
		x.play()

func change_track_volume(track_type:track_types,volume_linear:float,time = 3.0):
	var x = music_tracks[track_type]
	if x is AudioStreamPlayer:
		var tween = get_tree().create_tween()
		tween.tween_property(x,"volume_linear",volume_linear,time)

func change_active_music(value):
	active = int(value)
