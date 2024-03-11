extends Control

var sat : float
var vignet : float
# Called when the node enters the scene tree for the first time.

func _enter_tree():
	SignalManager.show_game_over.connect(gameFinish)

func _ready():
	sat = $Desat.material.get("shader_parameter/blur_amount")
	vignet = $Vignette.material.get("shader_parameter/vignette_opacity")
	$Desat.material.set("shader_parameter/blur_amount", 0.0)
	$Vignette.material.set("shader_parameter/vignette_opacity", 0.0)
	hide()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func gameFinish():
	show()
	get_tree().paused = true
	var tween : Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($Desat.material, "shader_parameter/blur_amount", sat, 0.1)
	tween.parallel().tween_property($Vignette.material, "shader_parameter/vignette_opacity", vignet,0.1)


func _on_restart_pressed():
	get_tree().reload_current_scene()


func _on_menu_pressed():
	var err = get_tree().change_scene_to_file("res://UI/main_menu.tscn")
