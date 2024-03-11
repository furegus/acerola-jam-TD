extends Area3D
class_name Projectile

@export var speed : float = 4.0
var damage : float = 1.0
var shootRange : float = 10

@onready var mesh = $Mesh

var isHit : bool = false

var startPosition: Vector3
var isShot : bool = false

var targetDirection : Vector3
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func configure(target : Vector3, dmg: float, range: float, model: Node3D):
	mesh.add_child(model)
	model.show()
	$CollisionShape3D.shape = SphereShape3D.new()
	$CollisionShape3D.shape.radius = 0.2
	damage = dmg
	shootRange = range
	isShot = true
	startPosition = global_position
	targetDirection = global_position.direction_to(target).normalized()

func _physics_process(delta):
	if isShot:
		global_position += targetDirection * speed * delta * GameManager.gameTimerSpeed
		if global_position.distance_to(startPosition) >= shootRange:
			queue_free()


func _on_body_entered(area):
	hit_target(area)


func hit_target(body):
	if isHit:
		return
	
	isHit = true
	var attackObj = Attack.new()
	attackObj.damage = damage
	body.damage(attackObj)
	queue_free()
