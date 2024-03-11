extends Resource
class_name Combatant

@export var name:String
@export var sprite:Texture2D
@export var description:String
@export var cost:int

@export var damage : int
@export var range : int
@export var speed : int

@export var mainAbility : PackedScene
@export var specialAbility : StringName


func calculateSpeedCooldown() -> float:
	var spd : float = 0
	
	match speed:
		0:
			spd = 100000000
		1:
			spd = 10
		2:
			spd = 4
		3:
			spd = 2.5
		4:
			spd = 1
		5:
			spd = 0.25
		6:
			spd = 0.1
	
	return spd

func calculateRange() -> float:
	var val : float = 0
	
	match range:
		0:
			val = 0
		1:
			val = 1
		2:
			val = 2
		3:
			val = 3
		4:
			val = 5
		5:
			val = 7.5
		6:
			val = 10000
	
	return val
