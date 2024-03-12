extends CharacterBody3D

@export var class_ID : Combatant:
	set(v):
		class_ID = v
		if Engine.is_editor_hint():
			sprite.texture = class_ID.sprite
@export var combatantName : String

var tile : Tile
var mainAbility
var specialAbility

var target : Node3D

@onready var attackRangeArea : Area3D = $AttackRange
@onready var attackRangeCollision : CollisionShape3D = $AttackRange/CollisionShape3D
@onready var rangeDebug : MeshInstance3D = $RangeDebug
@onready var sprite : Sprite3D = $Sprite3D


func _ready():
	# === CLASS ID SETUP === #
	sprite.texture = class_ID.sprite
	combatantName = class_ID.name
	mainAbility = class_ID.mainAbility.instantiate()
	$Abilities/Main.add_child(mainAbility)
	attackRangeCollision.shape = SphereShape3D.new()
	attackRangeCollision.shape.radius = class_ID.range
	# === THE REST === #
	rangeDebug.show()
	rangeDebug.mesh = SphereMesh.new()
	rangeDebug.mesh.radius = class_ID.calculateRange()

func _physics_process(delta):
	if !is_instance_valid(tile):
		return
	
	if !GameManager.isGameTimeRunning:
		return
	
	var brozure = null
	if attackRangeArea.has_overlapping_bodies():
		brozure = get_closest_area()
	
	ability_main(brozure)

func ability_main(target : Node3D = null):
	var loc = null
	if target && target.isWorking:
		if mainAbility.can_execute():
			$AnimationPlayer.play("attack")
		loc = target.global_position
	
	# create a execute function on the abilities which will perform it
	mainAbility.execute(self, loc)

func ability_special():
	# create a execute function on the abilities which will perform it
	pass

func OnField(_tile: Tile):
	$CollisionShape3D.disabled = false
	tile = _tile
	rangeDebug.hide()
	GameManager.map.use_coins(class_ID.cost)
	class_ID.cost += int(float(class_ID.cost)/19.0)
	$Coin.play()

func OffField():
	$CollisionShape3D.disabled = true
	rangeDebug.show()

func load_ability():
	pass

func get_closest_area() -> Node3D:
	var closestDist : float = 99999
	var closestTarget : Node3D = null
	
	for x : Node3D in attackRangeArea.get_overlapping_bodies():
		var newDist : float = global_position.distance_to(x.global_position)
		if newDist < closestDist:
			closestDist = newDist
			closestTarget = x
	
	return closestTarget


func _on_mouse_entered():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return
	rangeDebug.show()

func _on_mouse_exited():
	rangeDebug.hide()
