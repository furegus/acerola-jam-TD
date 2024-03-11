extends Node3D
class_name BaseManager


var baseList : Array = []

func _enter_tree():
	SignalManager.update_base.connect(_on_bases_updated)
	SignalManager.add_base_to_list.connect(_on_base_added)

func _ready():
	GameManager.base_manager = self


func _on_base_added(base):
	baseList.append(base)

func _on_bases_updated():
	await get_tree().create_timer(0.5).timeout
	baseList = Enhancements.check_and_erase(baseList)
	print(baseList)
	if baseList.is_empty():
		SignalManager.show_game_over.emit()
