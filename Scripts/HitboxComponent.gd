extends Area3D

@export var healthComponent : HealthComponent

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func damage(attack: Attack):
	if !healthComponent:
		return
	
	healthComponent.damage(attack)
