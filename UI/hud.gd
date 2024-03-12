extends Control

var press : bool = false
var tween : Tween

@onready var timeRemainingLabel : Label = $VBoxContainer/NextRound/HBoxContainer/time
@onready var enemyRemainingLabel : Label = $VBoxContainer/EnemiesLeft/HBoxContainer/current
@onready var enemyMaxLabel : Label = $VBoxContainer/EnemiesLeft/HBoxContainer/max
@onready var coinsLabel : Label = $CoinPanel/MarginContainer/HBoxContainer/coins
@onready var hpLabel : Label = $CoinPanel/MarginContainer/HBoxContainer/hearts

func _enter_tree():
	$VBoxContainer/NextRound.hide()
	$VBoxContainer/EnemiesLeft.hide()
	SignalManager.update_coins.connect(_on_coins_updated)
	SignalManager.update_base_health.connect(_on_base_health_updated)
	SignalManager.wave_changed.connect(_on_wave_changed)
	SignalManager.wave_started.connect(_on_wave_started)
	SignalManager.wave_timer_changed.connect(_on_wave_timer_changed)
	SignalManager.update_mob_count.connect(_on_mob_count_updated)
	
	SignalManager.combatant_placement_start.connect(_on_placement_start)
	SignalManager.combatant_placement_end.connect(_on_placement_end)

func _ready():
	GameManager.gameTimerSpeed = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_wave_started():
	$VBoxContainer/NextRound.hide()
	$VBoxContainer/EnemiesLeft.show()
	

func _on_wave_changed(waveCount: int, _waveCurrency):
	$VBoxContainer/NextRound.show()
	$VBoxContainer/EnemiesLeft.hide()
	$VBoxContainer/RoundInfo/Count.text = str(waveCount)
	_on_mob_count_updated()

func _on_wave_timer_changed(time: float):
	timeRemainingLabel.text = TimeConversion.s_to_string(time)

func _on_placement_start(_val):
	tween = create_tween()
	#tween.set_speed_scale(10)
	tween.tween_property($chroma_abb.material, "shader_parameter/aberration", 0.1, 0.2)
	tween.parallel().tween_property($vignette.material, "shader_parameter/vignette_opacity", 0.5, 0.2)

func _on_placement_end():
	tween = create_tween()
	tween.tween_property($chroma_abb.material, "shader_parameter/aberration", 0.0, 0.15)
	tween.tween_property($vignette.material, "shader_parameter/vignette_opacity", 0.16, 0.15)

func _on_mob_count_updated():
	await get_tree().create_timer(0.1).timeout
	
	var maxx = GameManager.mob_manager.mobWaveCount
	var curr = GameManager.mob_manager.mobKillTracker
	
	enemyMaxLabel.text = str(maxx)
	enemyRemainingLabel.text = str(curr)

func _on_coins_updated(c:int):
	coinsLabel.text = "$"+str(c)
	for x in $CombatantPanel/MarginContainer/HBoxContainer.get_children():
		x.disabled = x.class_ID.cost > c

func _on_base_health_updated(helth: int):
	hpLabel.text = str(helth)

func _on_next_button_pressed():
	if !GameManager.isGameTimeRunning:
		return
	
	if GameManager.gameTimerSpeed == 1:
		GameManager.gameTimerSpeed = 2
		$NextButton.icon = load("res://Assets/icons/FF.png")
	else:
		GameManager.gameTimerSpeed = 1
		$NextButton.icon = load("res://Assets/icons/Play.png")
		

func _on_pause_button_pressed():
	SignalManager.show_pause_menu.emit(true)
