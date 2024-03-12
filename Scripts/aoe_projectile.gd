extends Area3D
class_name AOEProjectile

var projSpeed : float = 2
var damage : float = 1.0
var shootRange : float = 10

@onready var mesh = $Mesh

var isHit : bool = false

var startPosition: Vector3
var isShot : bool = false
var gravityVal : float = 9.8

var targetDirection : Vector3
var targetPosition : Vector3
var controlPosition : Vector3


var projDeltaTime : float

func configure(target : Vector3, dmg: float, range: float, model: Node3D):
	mesh.add_child(model)
	model.show()
	$CollisionShape3D.shape = SphereShape3D.new()
	$CollisionShape3D.shape.radius = 0.3
	#$AOE/CollisionShape3D.shape = SphereShape3D.new()
	#$AOE/CollisionShape3D.shape.radius = 1.0
	damage = dmg
	shootRange = range
	isShot = true
	startPosition = global_position
	targetPosition = target # Set target position
	# set control point for bezier halfway across start and end
	controlPosition = global_position + global_position.direction_to(target)/ 2.0
	controlPosition.y = global_position.y + 2 # Setting height of control position

func _physics_process(delta : float):
	if isShot && !isHit:
		grav_movement(delta * GameManager.gameTimerSpeed)
		if projDeltaTime > 1:
			hit_target(null)


#func _on_body_entered(area):
	#hit_target(area)


func grav_movement(delta: float):
	global_position = evaluate_trajectory(projDeltaTime)
	projDeltaTime += delta * projSpeed


func evaluate_trajectory(delta):
	var ac := global_position.lerp(controlPosition, delta)
	var cb := controlPosition.lerp(targetPosition, delta)
	return ac.lerp(cb, delta)


func hit_target(_body):
	if isHit:
		return
	
	$AudioStreamPlayer.play()
	
	isHit = true
	var attackObj = Attack.new()
	attackObj.damage = damage
	#body.damage(attackObj)
	if $AOE.has_overlapping_bodies():
		for x in $AOE.get_overlapping_bodies():
			x.damage(attackObj)
	
	$Mesh.hide()
	$GPUParticles3D.restart()
	$GPUParticles3D2.restart()
	$GPUParticles3D3.restart()
	await get_tree().create_timer(1).timeout
	queue_free()
