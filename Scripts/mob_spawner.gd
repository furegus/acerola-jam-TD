extends Node3D
class_name Spawner

@export var disabled : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if disabled:
		return
	SignalManager.add_spawner_to_list.emit(self)

func enable():
	show()
	disabled = false
	SignalManager.add_spawner_to_list.emit(self)

