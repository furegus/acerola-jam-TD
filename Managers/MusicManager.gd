extends Node

const MUSIC_TRACK_DEFAULT := [preload("res://Assets/sfx/Free Funny Type Beat  PerVersion 3  Funny HipHop Beat 2022.mp3")]
const VOLUME_DEFAULT : float = -20.0

var music_track = MUSIC_TRACK_DEFAULT
var volume := VOLUME_DEFAULT
var audio_player : AudioStreamPlayer
var ui_audio_player : AudioStreamPlayer
var bandPass : AudioEffect
var bandPassCutoff : float = 0
var autoNext : bool = true
var loopLast : bool = true
var current : int = 0
var lastTime : float
var musicList : Array = MUSIC_TRACK_DEFAULT
#var time

func _enter_tree():
	bandPass = AudioServer.get_bus_effect(0,0)
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = music_track[0]
	audio_player.volume_db = volume
	audio_player.bus = ("Music")
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	add_child(audio_player)
#	audio_player.play()
	audio_player.finished.connect(_finished)
	
	# UI AUDIO STREAM SETUP
	ui_audio_player = AudioStreamPlayer.new()
	ui_audio_player.volume_db = volume
	ui_audio_player.bus = ("SFX")
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(ui_audio_player)
	#ui_audio_player.finished.connect(_finished)

func loop():
	if audio_player.get_playback_position() == 0:
		audio_player.play()

func SetStreamPause(val : bool):
	audio_player.stream_paused = val

func IsTrackPlaying(trackList : Array) -> bool:
	return musicList == trackList

func Default():
	ChangeTrack(MUSIC_TRACK_DEFAULT, VOLUME_DEFAULT, true)

## Used to change between loop tracks and set their volume
func ChangeTrack(trackList : Array, vol:= volume, contd : bool = false, fadeTime: float = 0.3):
	# Set track start to lastTime if the function has a contd value of TRUE
	var t :float = lastTime if contd else 0
	
	await _FadeToZero(fadeTime)
	SetStreamPause(true)
	lastTime = audio_player.get_playback_position()
	
	
	musicList = trackList
	current = 0
	audio_player.stream = trackList[0]
	#audio_player.volume_db = vol
	# We wait for 1 frame as it doesn't play otherwise
	await get_tree().process_frame
	audio_player.play(t)
	_FadeFromZero(fadeTime, vol)

func UiTrack(track: AudioStream):
	# Check if new track is the same as Old track, 
	#if not, we change track and add delay
	if ui_audio_player.stream != track:
		ui_audio_player.stream = track
		await get_tree().physics_frame
	
	ui_audio_player.play()

#
#func ChangeTrackWithCrossfade(trackList : Array, vol:= volume, contd : bool = false, fadeTime: float = 0.2):
		## Set track start to lastTime if the function has a contd value of TRUE
	#var t :float = lastTime if contd else 0
	#
	#print("Done")
	#SetStreamPause(true)
	#lastTime = audio_player.get_playback_position()
	#
	## Setting up new audio player to fade from old one
	#var _newAudioPlayer := audio_player.duplicate()
	#_newAudioPlayer.add_child(self)
	#
	#musicList = trackList
	#current = 0
	#_newAudioPlayer.stream = trackList[0]
	#_newAudioPlayer.volume_db = vol
	## We wait for 1 frame as it doesn't play otherwise
	#await get_tree().process_frame
	#SetStreamPause(false)
	#_newAudioPlayer.play(t)
	#
	#var tween = create_tween()
	#tween.tween_property(audio_player, "volume_db", -90, fadeTime)
	#tween.parallel().tween_property(_newAudioPlayer, "volume_db", vol, fadeTime)
	#
	#await tween.finished
	##audio_player.free()
	#audio_player = _newAudioPlayer

func _FadeToZero(fadeTime:float):
	var tween : Tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(audio_player, "volume_db", -90, fadeTime)
	await tween.finished

func _FadeFromZero(fadeTime:float, vol:float):
	#audio_player.volume_db = -90
	var tween : Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(audio_player, "volume_db", vol, fadeTime/2.0)

#func _CrossFade(fadeTime:float, newVol:float):
	
func Reset():
	musicList = MUSIC_TRACK_DEFAULT
	current = 0
	volume = VOLUME_DEFAULT
	lastTime = 0

## Stop the audio player and goto start
func Stop():
	audio_player.stop()

## This is going to be used for crossfades if implemented
func DepricateOld():
	pass

func _next() -> bool:
	if current < musicList.size() - 1:
		current += 1
		audio_player.stream = musicList[current]
		return true
	return false

func _finished():
	if !autoNext:
		return
	if !loopLast and current >= musicList.size():
		return
	_next()
	audio_player.play()

func EnableBandpass():
	AudioServer.set_bus_bypass_effects(0, false)
	bandPassCutoff = 600
	var tween : Tween = self.create_tween()
	tween.tween_property(bandPass, "cutoff_hz", bandPassCutoff, 0.1)

func DisableBandpass():
	AudioServer.set_bus_bypass_effects(0, true)
	bandPassCutoff = 20500
	var tween : Tween = self.create_tween()
	tween.tween_property(bandPass, "cutoff_hz", bandPassCutoff, 0.1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#if bandPass.cutoff_hz != bandPassCutoff:
		
