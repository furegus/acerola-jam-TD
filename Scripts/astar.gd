extends Node3D
class_name AstarHandler

var pointList = {}
var astar : AStar2D

@onready var gridmap : GridMap = $GridMap

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.astarHandler = self
	gridmap.hide()
	
	astar = AStar2D.new()
	var cells = gridmap.get_used_cells()
	for cell in cells:
		cell = Vector2(cell.x, cell.z)
		var index := astar.get_available_point_id()
		astar.add_point(index, cell)
		pointList[v2_to_index(cell)] = index
	
	for cell in cells:
		cell = Vector2(cell.x, cell.z)
		for x in [-1, 0, 1]:
			for y in [-1, 0, 1]:
				var vec2 = Vector2(x,y)
				if vec2 == Vector2.ZERO:
					continue
				if v2_to_index(vec2+cell) in pointList:
					if cell.x != (vec2+cell).x && cell.y != (vec2+cell).y:
						continue
					var index1 = pointList[v2_to_index(cell)]
					var index2 = pointList[v2_to_index(cell+vec2)]
					if !astar.are_points_connected(index1, index2):
						astar.connect_points(index1, index2)

func v2_to_index(v2: Vector2):
	return StringName(str(int(round(v2.x))) + "," + str(int(round(v2.y))))

func GetPath(start: Vector3, end: Vector3) -> PackedVector2Array:
	#var start_vec2 := Vector2(gridmap.local_to_map(start).x, gridmap.local_to_map(start).z)
	var start_vec2 := Vector2((start).x, (start).z)
	#var end_vec2 := Vector2(gridmap.local_to_map(end).x, gridmap.local_to_map(end).z)
	var end_vec2 := Vector2((end).x, (end).z)
	var grid_start = v2_to_index(start_vec2)
	var grid_end = v2_to_index(end_vec2)
	var start_id = 0
	var end_id = 0
	if grid_start in pointList:
		start_id = pointList[grid_start]
	else:
		start_id = astar.get_closest_point(start_vec2)
	
	if grid_end in pointList:
		end_id = pointList[grid_end]
	else:
		end_id = astar.get_closest_point(end_vec2)
	
	var path := astar.get_point_path(start_id, end_id)
	if path[-1] != end_vec2:
		path.append(end_vec2)
	return path


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
