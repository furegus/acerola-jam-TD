extends Node3D
class_name MobManager

const BAT = preload("res://Scenes/Mobs/bat.tres")

@export var maxMobCount : int = 10
@export var waveMobHolder : Node
@export var mobBase : PackedScene

var minSpawnInterval : float = 0.075
var spawnInterval : float = 1.0
var deltaTimer: float = 0.0

var targetList := []
var spawnerList : Array[Spawner] = []

var running : bool = false

var mobCount : int = 0
var waveCount : int = 1
var mobWaveCount : int = 0 # Max mobs in wave
var mobKillTracker : int = 0

var mobClassList : Array
var mobIndex : int

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	SignalManager.add_base_to_list.connect(_AddBaseToList)
	SignalManager.add_spawner_to_list.connect(_add_spawner_to_list)
	SignalManager.wave_changed.connect(_on_wave_changed)
	SignalManager.wave_started.connect(_on_wave_started)
	SignalManager.update_mob_count.connect(_on_mob_count_changed)
	#SignalManager.remove_spawner_from_list.connect(_on_spawner_removed)
	
	randomize()

func _ready():
	GameManager.mob_manager = self
	mobClassList = mobs_in_wave(1)

func _process(delta):
	#print(deltaTimer)
	if !running:
		return
	
	if mobCount <=0:
		return
	
	deltaTimer += delta * GameManager.gameTimerSpeed
	if deltaTimer >= spawnInterval:
		deltaTimer -= spawnInterval
		spawn()

func spawn():
	if spawnerList.is_empty():
		return
	#print(mobClassList)
	mobCount -= 1
	var spawnerSelected : Spawner = get_random_spawner()
	var mob = mobBase.instantiate()
	if mobIndex >= mobClassList.size():
		mobIndex = 0
	mob.class_ID = mobClassList[mobIndex]
	mobIndex += 1
	
	
	$Holder.add_child(mob)
	mob.global_position = spawnerSelected.global_position

func get_random_spawner() -> Spawner:
	return spawnerList[randi()%spawnerList.size()]

func _AddBaseToList(base: Node3D):
	targetList.append(base)

func _add_spawner_to_list(spawner: Spawner):
	spawnerList.append(spawner)

func get_closest_target_base(startPosition: Vector3) -> PackedVector2Array:
	var path : Array = []
	
	targetList = Enhancements.check_and_erase(targetList)
	if targetList.size()>0:
		for x in targetList:
			var astar: AstarHandler = GameManager.astarHandler as AstarHandler
			var p := astar.GetPath(startPosition, x.global_position)
			if path.is_empty():
				path = p
			if p.size() < path.size():
				path = p
		
	return path

func mobs_in_wave(wav : int) -> Array:
	if !is_instance_valid(waveMobHolder):
		return []
	if waveMobHolder.get_child_count() == 0:
		return []
	
	var node : WaveMobs
	if waveMobHolder.get_child_count() > wav:
		node = waveMobHolder.get_child(wav-1) # Return child wave
	else:
		node = (waveMobHolder.get_child(-1))
	
	return node.mobList

func has_target_moved(estimatedPosition: Vector2) -> bool:
	var b : bool = true
	
	# Converting position to vector3
	var posVec3 = Vector3(estimatedPosition.x,0,estimatedPosition.y)
	
	targetList = Enhancements.check_and_erase(targetList)
	if targetList.size()>0:
		for x in targetList:
			posVec3.y = x.global_position.y
			if x.global_position == posVec3:
				b = false
				return b
	
	return b


#func _on_spawner_removed(spawner: Spawner):
	#targetList.erase(spawner)

func _on_wave_started():
	running = true
	

func _on_wave_changed(waveN: int, _waveCurrency : int):
	running = false
	waveCount = waveN
	spawnInterval -= (0.075)
	spawnInterval = max(spawnInterval, minSpawnInterval)
	mobCount = maxMobCount * waveCount
	mobKillTracker = mobCount
	mobWaveCount = mobCount
	
	# === Picking Mob Weights === #
	var mobs := mobs_in_wave(waveN)
	var cash = waveN * 2
	var list := []
	
	while cash > 0:
		var x : Mob = mobs.pick_random()
		if cash < x.cost:
			continue
		list.append(x)
		cash -= x.cost
	
	mobClassList = list

func _on_mob_count_changed():
	mobKillTracker -= 1
	if mobKillTracker <= 0:
		GameManager.waveHandler.next_wave()
