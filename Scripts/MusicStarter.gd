extends Node

@export var delay : float = 0.2
# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(delay).timeout
	if MusicManager.musicList[0] != MusicManager.MUSIC_TRACK_DEFAULT[0]:
		MusicManager.Default()
	MusicManager.SetStreamPause(false)
	#MusicManager.loop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
