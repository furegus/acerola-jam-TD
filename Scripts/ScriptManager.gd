extends Node

const explosion = preload("res://Scenes/Particles/explosion.tscn")

var waveRecord : int = 0
var astar: AstarHandler
var hasExplosion: bool = false

@onready var base = $"../../BaseManager/Base"
func _ready():
	SignalManager.wave_changed.connect(event_happening)
	astar = GameManager.astarHandler


func event_happening(wave: int, _curr):
	if waveRecord == wave:
		return
	waveRecord = wave
	hasExplosion = false
	var saveLoc = GameManager.pan_camera.global_position
	var timescale = GameManager.gameTimerSpeed
	GameManager.gameTimerSpeed = 0
	match wave:
		3:
			explode_tile($"../../Environment/acerola_jam0_map/TileCollection/Tile_145")
			await GameManager.pan_camera.move_to_global_location($Marker3D1_1.global_position)
			
		4:
			await GameManager.pan_camera.move_to_global_location($Marker3D.global_position)
			await GameManager.map.show_block($"../../Environment/Block2")
			explode_tile($"../../Environment/acerola_jam0_map/TileCollection/Tile_250")
			explode_tile($"../../Environment/acerola_jam0_map/TileCollection/Tile_249")
			explode_tile($"../../Environment/acerola_jam0_map/TileCollection/Tile_085")
			explode_tile($"../../Environment/acerola_jam0_map/TileCollection/Tile_086")
			#explode_tile($"../../Environment/acerola_jam0_map/TileCollection/Tile_097")
			$"../../Environment/Block2/MobSpawner3".enable()
			GameManager.waveHandler.reset_wave()
		
		5:
			explode_tile($"../../Environment/acerola_jam0_map/TileCollection/Tile_225")
			explode_tile($"../../Environment/acerola_jam0_map/TileCollection/Tile_231")
		
		6:
			#GameManager.isGameTimeRunning = false
			await GameManager.pan_camera.move_to_global_location($Marker3D.global_position)
			base.change_location($"../../BaseManager/Markers/BaseMarker2")
			await base.move_finished
		
		7:
			await GameManager.pan_camera.move_to_global_location($Marker3D2.global_position)
			$"../../Environment/Block2/MobSpawner4".enable()
			$"../../Environment/Block2/MobSpawner5".enable()
			explode_tile($"../../Environment/Block2/Tiles/Tile_055")
			explode_tile($"../../Environment/Block2/Tiles/Tile_182")
			GameManager.waveHandler.reset_wave()
		
		8:
			await GameManager.pan_camera.move_to_global_location($Marker3D3.global_position)
			await GameManager.map.show_block($"../../Environment/Block4")
			
			$"../../Environment/Block4/MobSpawner".enable()
			GameManager.waveHandler.reset_wave()
		
		9:
			await GameManager.pan_camera.move_to_global_location($Marker3D3.global_position)
			base.change_location($"../../BaseManager/Markers/BaseMarker5")
			await base.move_finished
			
		
		11:
			await GameManager.pan_camera.move_to_global_location($Marker3D4.global_position)
			await GameManager.map.show_block($"../../Environment/Block3")
			$"../../Environment/Block3/MobSpawner2".enable()
			GameManager.waveHandler.reset_wave()
			
		
	# === RESET BACK TO THE START === #
	if GameManager.pan_camera.global_position.distance_to(saveLoc)>1:
		await get_tree().create_timer(0.5).timeout
		await GameManager.pan_camera.move_to_global_location(saveLoc) # Reset cam
	
	GameManager.gameTimerSpeed = timescale # Reset time
	
	if hasExplosion:
		astar.generate_map()
	

func explode_tile(val: Tile, intensity: float = 0.5):
	GameManager.pan_camera.add_trauma(intensity)
	
	$AudioStreamPlayer.play()
	var loc = val.global_position
	var expl = explosion.instantiate()
	GameManager.map.add_child(expl)
	expl.global_position = loc
	expl.explode_with_rand_offset()
	val.destroy_tile()
	
	hasExplosion = true
	astar.add_path_to_grid(loc)
	
