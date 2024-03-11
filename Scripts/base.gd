@tool
extends Node3D

@export var disabled : bool = false
@export var health: int = 10:
	set(v):
		health = v
@export var canMove: bool = false
@export var moveBufferTime : float = 60

var isMoving : bool = false:
	set(v):
		isMoving = v
		if !canMove:
			return
		if v: $MovingTimer.start()
		else: $MovingTimer.stop()

var firstTime : bool = true

var deltaTimer : float = 0

var currentMarker : Node3D

@onready var healthComponent: HealthComponent = $HealthComponent

func _enter_tree():
	if Engine.is_editor_hint():
		return
	$HealthComponent.max_health = health
	$HealthComponent.dead.connect(_on_death)

func _ready():
	if Engine.is_editor_hint():
		return
	
	if disabled:
		return
	
	SignalManager.add_base_to_list.emit(self)
	$AnimationPlayer.play("hover")
	if canMove:
		deltaTimer = moveBufferTime
		currentMarker= get_tree().get_first_node_in_group("baseMarker")
		currentMarker.global_position.y = global_position.y
		global_position = currentMarker.global_position
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		return
	
	if !canMove || isMoving:
		return
	#deltaTimer -= delta
	#if deltaTimer <= 0:
		#change_location()

#func _physics_process(delta):
	#if Engine.is_editor_hint():
		#return
	#
	#

func _on_death():
	SignalManager.update_base.emit()
	queue_free()

func _on_hitbox_component_body_entered(body):
	if disabled:
		return
	body.queue_free()
	# Create attack object
	var atk = Attack.new()
	atk.damage = 1
	# feed to health function
	healthComponent.damage(atk)
	print(name,healthComponent.current_health)
	SignalManager.update_mob_count.emit()

func change_location():
	deltaTimer = moveBufferTime
	# Check to see if we even are changing locations
	var ischanging : bool = [false,true].pick_random()
	if firstTime:
		ischanging = true
		firstTime = false
	
	if !ischanging:
		return
	
	print("CHANGE TIME")
	currentMarker = fetch_random_marker()
	if currentMarker == null:
		return
	movement()

func fetch_random_marker() -> Node3D:
	var list := get_tree().get_nodes_in_group("baseMarker")
	list.erase(currentMarker)
	for x in list:
		if x.disabled:
			list.erase(x)
	if list.is_empty():
		return null
	return list[randi()%list.size()]


func movement():
	isMoving = true
	var dist : float = global_position.distance_to(currentMarker.global_position)
	#var final = to_local(currentMarker.global_position)
	var final = currentMarker.position
	final.y = global_position.y
	var tween : Tween = create_tween()
	tween.set_loops(1)
	tween.tween_property(self, "position", position + Vector3(0, 1.5, 0), 3) # Move Up
	tween.chain().tween_property(self, "position", final + Vector3(0, 1.5, 0), dist) # Move to Node
	tween.chain().tween_property(self, "position", final, 3) # Move Down
	await tween.finished
	isMoving = false


func _on_moving_timer_timeout():
	if isMoving:
		SignalManager.update_base.emit()


