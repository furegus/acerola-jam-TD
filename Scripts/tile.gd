extends MeshInstance3D
class_name Tile

const FALLBACK_HIGHLIGHT : String = "res://Scenes/tileHighlight.tres"

@export var _highlight_mesh: Mesh
var highlightMesh : MeshInstance3D
var highlightArea : Area3D

@export var _tile_size : Vector2 = Vector2.ONE

var tileAABB : AABB
var raycast : RayCast3D

var isMouseInside : bool = false
var tiledObject : Node3D = null
var tileObjectTargetPosition : Vector3
var isTileOccupied : bool = false:
	set(v):
		isTileOccupied = v
		if v:
			highlightArea.process_mode =Node.PROCESS_MODE_DISABLED
			
		else:
			highlightArea.process_mode =Node.PROCESS_MODE_INHERIT

# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_instance_valid(_highlight_mesh):
		if not FileAccess.file_exists(FALLBACK_HIGHLIGHT):
			return
		else:
			_highlight_mesh = load(FALLBACK_HIGHLIGHT)
	
	_setup()
	await get_tree().create_timer(0.1).timeout
	IntersectionCheck()
	


func _setup():
	add_to_group("Tile")
	tileAABB = mesh.get_aabb()
	highlightMesh = MeshInstance3D.new()
	highlightMesh.mesh = _highlight_mesh
	add_child(highlightMesh)
	highlightMesh.scale = Vector3.ZERO
	
	# Set position for spawning tiles and Collision
	var newPos : Vector3 = tileAABB.get_center() + Vector3.UP * tileAABB.size * 0.6
	tileObjectTargetPosition = newPos
	# Set tile mesh position
	highlightMesh.position = newPos
	#  and Shadow
	highlightMesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	# Create Highlight Check Area
	highlightArea = Area3D.new()
	add_child(highlightArea)
	highlightArea.position = newPos
	# collision for the area
	var col: CollisionShape3D = CollisionShape3D.new()
	highlightArea.add_child(col)
	# If Game Manager doesn't have collision shape create One
	if not is_instance_valid(GameManager.tileCollisionShape):
		var _shape = BoxShape3D.new()
		_shape.size = Vector3(_tile_size.x, 0.3, _tile_size.y)
		col.shape = _shape
		GameManager.tileCollisionShape = _shape
	
	# If Game Manager has the tile, then share it
	else:
		col.shape = GameManager.tileCollisionShape
	
	# Set Area Signal
	highlightArea.mouse_entered.connect(AreaMouseEnter)
	highlightArea.mouse_exited.connect(AreaMouseExit)
	SignalManager.combatant_placement_start.connect(StartHighlightTile)
	SignalManager.combatant_placement_end.connect(EndHighlightTile)
	


func IntersectionCheck(forceTrue : bool = false):
	if is_instance_valid(highlightArea):
		if highlightArea.get_overlapping_bodies().size() > 0:
			tiledObject = highlightArea.get_overlapping_bodies()[0]
		#elif highlightArea.get_overlapping_areas().size() > 0:
			#tiledObject = highlightArea.get_overlapping_areas()[0]
			
		if (tiledObject):
			isTileOccupied = true
		else:
			isTileOccupied = forceTrue
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func AssignCombatant(combatant):
	tiledObject = combatant
	isTileOccupied = true
	combatant.OnField(self)

func AreaMouseEnter():
	if !is_instance_valid(GameManager.pan_camera):
		return
		
	isMouseInside = true
	
	if !isTileOccupied:
		GameManager.pan_camera.PlacementOverrideStart(global_position + tileObjectTargetPosition, self)
		#highlightMesh.show()

func AreaMouseExit():
	isMouseInside = false
	
	if !isTileOccupied:
		GameManager.pan_camera.dragPosOverride = false
	#highlightMesh.hide()

func StartHighlightTile(_val):
	if isTileOccupied:
		return
	#if is_instance_valid(tiledObject):
		#print("HOYA?")
	highlightMesh.scale = Vector3.ZERO
	highlightMesh.show()
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(highlightMesh, "scale", Vector3.ONE, 0.3)

func EndHighlightTile():
	highlightMesh.scale = Vector3.ZERO
	highlightMesh.hide()
	if isMouseInside:
		AssignCombatant(GameManager.pan_camera.pickedCombatant)
