extends Control

var sat : float
var vignet : float
# Called when the node enters the scene tree for the first time.

var isPaused : bool = false

func _enter_tree():
	SignalManager.show_pause_menu.connect(paused)
	hide()

func _ready():
	pass


func paused(pauseState : bool = !isPaused):
	if !pauseState:
		hide()
		get_tree().paused = false
		isPaused = false
	else:
		show()
		get_tree().paused = true
		isPaused = true


func _on_restart_pressed():
	get_tree().reload_current_scene()


func _on_menu_pressed():
	var err = get_tree().change_scene_to_file("res://UI/main_menu.tscn")


func _on_resume_pressed():
	paused(false)


