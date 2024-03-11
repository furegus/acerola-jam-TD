extends Node
class_name HealthComponent

@export var max_health : int = 10
var current_health : int

signal dead
# Called when the node enters the scene tree for the first time.
func _ready():
	current_health = max_health


func damage(attack: Attack):
	current_health -= attack.damage
	if current_health <= 0:
		# To be replaced with a death signal
		dead.emit()
	
