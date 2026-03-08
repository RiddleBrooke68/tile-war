extends Node

@export var track_active = 1:
	set(i):
		last_track_active = track_active
		track_active = i
		repeat_checks()
var last_track_active = 1
@export var playing = false:
	set(i):
		if plays != i:
			if i:
				play()
			else:
				stop()
		playing = i
		plays = i
@export var volume = 1.0:
	set(i):
		for x in track_list.keys():
			change_track_volume(x,track_list[x].volume_linear*i,0.0,false)
		volume = i
@export var music : battle_music_data

var plays = false

enum track_types {
	base, green, purple, yellow, red, blue
}

var track_list = {
	track_types.base:null,
	track_types.green:null,
	track_types.purple:null,
	track_types.yellow:null,
	track_types.red:null,
	track_types.blue:null
}


func _ready():
	refresh()
	repeat_checks()

func refresh():
	for i in range(track_types.size()):
		var x = AudioStreamPlayer.new()
		var m = music.give_track(i)
		if m is AudioStreamMP3 or m is AudioStreamOggVorbis:
			m.loop = true
		x.stream = m
		x.add_to_group("battle_music")
		add_child(x)
		track_list[i] = x
		x.volume_linear = 0

func play():
	plays = true
	playing = true
	for i in track_types:
		play_track(track_types[i])
		if track_types[i] > 0:
			change_track_volume(track_types[i],0)

func stop():
	plays = false
	playing = false
	for i in track_types:
		stop_track(track_types[i])

func repeat_checks():
	for i in track_list.keys():
		change_track_volume(i, 
							Global.music_vol*volume/10.0 if i in [track_active,0] else 0.0 if not i in [last_track_active] else Global.music_vol*volume/10.0*4/5.0, 
							8.0 if not i in [track_active,last_track_active,0] else 2.0)

func play_track(track_type:track_types):
	var x = track_list[track_type]
	if x is AudioStreamPlayer:
		if x.stream is AudioStreamMP3 or x.stream is AudioStreamOggVorbis:
			x.play()

func stop_track(track_type:track_types):
	var x = track_list[track_type]
	if x is AudioStreamPlayer:
		if x.stream is AudioStreamMP3 or x.stream is AudioStreamOggVorbis:
			x.stop()

var actively_tweening = []

func change_track_volume(track_type:track_types,volume_linear:float,time = 3.0,do_tween=true):
	var x = track_list[track_type]
	if x is AudioStreamPlayer and x.playing == true and not x in actively_tweening:
		if volume_linear != x.volume_linear:
			if do_tween:
				actively_tweening.append(x)
				var tween = get_tree().create_tween()
				tween.tween_property(x,"volume_linear",volume_linear,time).set_ease(Tween.EASE_OUT)
				tween.tween_callback(track_tweend.bind(x,tween)).set_delay(time)
			else:
				x.volume_linear = volume_linear

func track_tweend(track,tween):
	actively_tweening.remove_at(actively_tweening.find(track))
	if tween is Tween:
		tween.kill()

func change_active_music(value):
	track_active = int(value)
