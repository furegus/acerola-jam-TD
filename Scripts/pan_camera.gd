extends SpringArm3D
class_name PanCamera

@export var noise : FastNoiseLite
@export var noiseSpeed : float = 50.
@export var maxRotation : Vector3 = Vector3(10,10,5)
@export_flags_3d_physics var raycastMask : = 0

const MAX_ZOOM : float = 1.
const MIN_ZOOM : float = 0.3
const ZOOM_INCREMENT: float = 0.1
const ZOOM_MULTIPLIER : float = 30
const ZOOM_RATE: float = 8.0
const MAX_ROT : float = 75
const MIN_ROT : float = 45
const ROT_INCREMENT : float = 4
const PAN_MULTIPLIER : float = 0.05

const RAY_LENGTH = 1000

var dragging : bool = false
var dragPosOverride : bool = false
var overrideTile : Tile

var zoom : float = 0.5
var _targetZoom: float = 0.5
var _targetRot : float = 55
# === Camera Shake Variables === #
var initialRotation : Vector3
var inTrauma : bool = false
var trauma : float = 0
var traumaReductionRate : float = 1.0

var pickedCombatant : Node3D

@onready var camera : Camera3D = $Camera3D
# Called when the node enters the scene tree for the first time.
func _ready():
	dragPosOverride = false
	initialRotation = rotation_degrees
	GameManager.pan_camera = self
	SignalManager.combatant_placement_start.connect(PlacementStart)
	SignalManager.combatant_placement_end.connect(PlacementEnd)
	#rotation_degrees.x = 65

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			position.x -= event.relative.x * zoom * PAN_MULTIPLIER
			position.z -= event.relative.y * zoom * PAN_MULTIPLIER
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				ZoomIn()
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				ZoomOut()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if inTrauma: # Making sure camera shake doesn't stop
		trauma = max(trauma - delta * traumaReductionRate, 0)
		#camera.rotation_degrees.x = initialRotation.x + maxRotation.x * get_shake_intensity() * get_noise_from_seed(0)
		camera.rotation_degrees.y = initialRotation.y + maxRotation.y * get_shake_intensity() * get_noise_from_seed(1)
		camera.rotation_degrees.z = initialRotation.z + maxRotation.z * get_shake_intensity() * get_noise_from_seed(2)
		if trauma == 0:
			inTrauma = false
	else:
		zoom = lerp(zoom, _targetZoom, ZOOM_RATE * delta)
		# add zoom multiplier while setting springarm
		spring_length = zoom * ZOOM_MULTIPLIER
		rotation_degrees.x = lerp(rotation_degrees.x, -_targetRot, ZOOM_RATE * delta)
		#$Camera3D/MeshInstance3D.material_override.set_shader_parameter("focal_point", global_position)
		# disable processing when zoom achieved
		set_process(snappedf(zoom, 0.01) != snappedf(_targetZoom, 0.01))
	

func _physics_process(delta):
	if inTrauma:
		if dragging:fetus_deletus()
		return
	
	if !dragging:
		return
	if dragPosOverride:
		return
	if !is_instance_valid(pickedCombatant):
		return
	
	var space_state = get_world_3d().direct_space_state
	var cam = $Camera3D
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end, raycastMask)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result = space_state.intersect_ray(query)
	#print(result)
	pickedCombatant.global_position = result.position


func ZoomIn():
	_targetZoom = maxf(_targetZoom - ZOOM_INCREMENT, MIN_ZOOM)
	_targetRot = maxf(_targetRot - ROT_INCREMENT, MIN_ROT)
	set_process(true)

func ZoomOut():
	_targetZoom = minf(_targetZoom + ZOOM_INCREMENT, MAX_ZOOM)
	_targetRot = minf(_targetRot + ROT_INCREMENT, MAX_ROT)
	
	set_process(true)
	

func PlacementStart(val: Node3D):
	if !val:
		return
	SmoothTweenRot(Vector3(0,3,0), 58)
	dragging = true
	pickedCombatant = val
	GameManager.combatantParent.add_child(pickedCombatant)
	#camera.fov -= 5

func PlacementEnd():
	if !dragging:
		return
	
	if !dragPosOverride:
		pickedCombatant.queue_free()
	SmoothTweenRot(Vector3(0,0,0), 60)
	dragging = false

func fetus_deletus():
	if !dragging:
		return
	dragging = false
	pickedCombatant.queue_free()
	SmoothTweenRot(Vector3(0,0,0), 60)

func SmoothTweenRot(rot: Vector3, fov: float):
	var tween : Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera, "rotation_degrees", rot, 0.2)
	tween.parallel().tween_property(camera, "fov", fov, 0.2)

func PlacementOverrideStart( dragPos : Vector3, tile : Tile):
	if !dragging:
		return
	
	if !is_instance_valid(pickedCombatant):
		return
	
	dragPosOverride = true
	pickedCombatant.global_position = dragPos
	overrideTile = tile
	

func move_to_global_location(pos : Vector3):
	pos.y = global_position.y
	var tween := create_tween()
	
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_loops(1)
	tween.tween_property(self, "global_position", pos, 0.5)
	var t = GameManager.gameTimerSpeed
	GameManager.gameTimerSpeed = 0
	await tween.finished
	GameManager.gameTimerSpeed = t
	return true

func add_trauma(trauma_amount: float):
	inTrauma = true
	set_process(true)
	trauma = clampf(trauma + trauma_amount, 0., 1.)
	

func get_shake_intensity() -> float:
	return trauma * trauma

func get_noise_from_seed(_seed : int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(Time.get_ticks_msec() * noiseSpeed)
