extends Node3D

var coins : int = 300
# Called when the node enters the scene tree for the first time.
func _enter_tree():
	GameManager.combatantParent = $Combatant
	GameManager.map = self
	GameManager.ui = $CanvasLayer/UICollection
	get_tree().paused = false

func _ready():
	add_coins(0)
	$Environment/Block2.position.y = -100
	$Environment/Block2.hide()
	#$FakeSky.show()

func add_coins(val:int):
	coins += val
	SignalManager.update_coins.emit(coins)

func use_coins(val:int):
	add_coins(-val)

func can_buy():
	return

func show_block(node:Node3D):
	node.show()
	var pos = node.position
	pos.y = 0
	var tween := create_tween()
	tween.tween_property(node, "position", pos, 2)
	
