extends Node

@export var projectile : PackedScene

var damage : float = 2
var range : float = 2
var cooldown = 1

var isRunning : bool = false
var onCooldown : bool = false

var timerTime: float
var timerDelta: float

func _ready():
	$Mesh.hide()

func _process(delta):
	if !onCooldown:
		return
	if !GameManager.isGameTimeRunning:
		return
	
	if timerTime > timerDelta:
		timerDelta += delta * GameManager.gameTimerSpeed
	else:
		onCooldown = false
	


func execute(selfObject: Node3D, target = null):
	if onCooldown:
		return
	if !target:
		return
	
	var stats := selfObject.class_ID as Combatant
	cooldown = stats.calculateSpeedCooldown()
	
	var dir := selfObject.global_position.direction_to(target)
	
	var p = projectile.instantiate()
	GameManager.map.add_child(p)
	
	p.global_position = Vector3(
		selfObject.global_position.x + dir.x * 0.5, # starting x position
		selfObject.global_position.y,
		selfObject.global_position.z + dir.z * 0.5 # starting z position
	)
	var mesh = $Mesh.duplicate()
	p.configure(target, stats.damage, stats.range, mesh)
	
	p.look_at(target)
	isRunning = true
	
	start_timer(cooldown)
	onCooldown = true

func can_execute() -> bool:
	return !onCooldown

func start_timer(t):
	timerTime = t
	timerDelta = 0

func _on_timer_timeout():
	onCooldown = false
