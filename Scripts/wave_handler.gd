extends Node
class_name WaveHandler

@export var maxWaves : int = 13
@export var autoNext : bool = true
var currentWave : int = 0
var waveCurrencyMult : int = 10
var waveCurrency : int = 0
var waveRestTime : int = 15
var waveTimer : float = 0


var running : bool = false


func _ready():
	GameManager.waveHandler = self
	next_wave()

func _process(delta):
	if !GameManager.isGameTimeRunning:
		return
	if !running:
		waveTimer -= delta * GameManager.gameTimerSpeed
		SignalManager.wave_timer_changed.emit(waveTimer)
		
		if waveTimer <= 0:
			_start_wave()

func next_wave():
	reset_wave(1)

func reset_wave(val : int = 0):
	if currentWave < maxWaves:
		waveTimer = waveRestTime
		currentWave += val
		running = false
		waveCurrency = currentWave * waveCurrencyMult
		SignalManager.wave_changed.emit(currentWave, waveCurrency)
	
	else:
		$"../../CanvasLayer/UICollection/GameWinMenu".gameFinish()

func _start_wave():
	running = true
	SignalManager.wave_started.emit()
	# Fire off signal for starting mob generation

func is_wave_running() -> bool:
	return running


