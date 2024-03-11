extends Node

const explosion = preload("res://Scenes/Particles/explosion.tscn")

var waveRecord : int = 0
# Called when the node enters the scene tree for the first time.
func _enter_tree():
	SignalManager.wave_changed.connect(event_happening)

func event_happening(wave: int, _curr):
	print("huh")
	if waveRecord == wave:
		return
	waveRecord = wave
	
	match wave:
		4:
			GameManager.map.show_block($"../../Environment/Block2")
			explode_at_node($"../../Environment/acerola_jam0_map/TileCollection/Tile_250")
			explode_at_node($"../../Environment/acerola_jam0_map/TileCollection/Tile_249")
			explode_at_node($"../../Environment/acerola_jam0_map/TileCollection/Tile_085")
			explode_at_node($"../../Environment/acerola_jam0_map/TileCollection/Tile_086")
			$"../../Environment/Block2/MobSpawner3".enable()
			GameManager.waveHandler.reset_wave()

func explode_at_node(val: Node):
	var loc = val.global_position
	var expl = explosion.instantiate()
	GameManager.map.add_child(expl)
	expl.global_position = loc
	expl.explode_with_rand_offset()
	val.hide()
