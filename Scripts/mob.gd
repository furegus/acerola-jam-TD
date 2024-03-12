extends CharacterBody3D

@export var MOVE_SPEED :float = 2

@export var class_ID : Mob
@export var customYBillboard: bool = true

var combatantName : String
# Path specific variables
var path := []
var pathIndex = 0
var isWorking := false
#@onready var astar
@onready var astar : AstarHandler

var dying : bool = false

func _enter_tree():
	class_setup()
	SignalManager.update_base.connect(_on_bases_updated)
	$HealthComponent.dead.connect(_on_death)
	MOVE_SPEED += randf_range(-0.1,0.1)

func _ready():
	add_to_group("mobs")
	astar = GameManager.astarHandler
	
	await get_tree().create_timer(0.4).timeout
	move_to_base()
	isWorking = true

func class_setup():
	if class_ID == null:
		return
	$Sprite3D.texture = class_ID.sprite
	combatantName = class_ID.name
	$HealthComponent.max_health = class_ID.hp

func _physics_process(delta):
	if !GameManager.isGameTimeRunning:
		return
	if pathIndex < path.size():
		# Convert Vector2 path to Vector3
		var targetVec : Vector3 = Vector3(path[pathIndex].x, global_position.y, path[pathIndex].y)
		var moveVec : Vector3 = (targetVec - global_position)
		if moveVec.length() < 0.1:
			next_node()
		else:
			velocity = moveVec.normalized() * MOVE_SPEED * GameManager.gameTimerSpeed
			move_and_slide()

func move_to_base():
	var mobManager : MobManager = GameManager.mob_manager
	#var mobManager = GameManager.mob_manager
	if path.is_empty() || mobManager.has_target_moved(path[-1]):
		path = mobManager.get_closest_target_base(global_position)
		pathIndex = 0

func next_node():
	pathIndex += 1
	#if path[pathIndex]:
		#pass


func OnField(_tile: Tile):
	$CollisionShape3D.disabled = false
	#
#
func OffField():
	$CollisionShape3D.disabled = true

func damage(atk : Attack):
	$HealthComponent.damage(atk)

func _on_death():
	if dying:
		return
	dying = true
	SignalManager.update_mob_count.emit()
	if !class_ID:
		return
	GameManager.map.add_coins(class_ID.coinReward)
	queue_free()

func _on_bases_updated():
	await get_tree().create_timer(0.25).timeout
	move_to_base()
