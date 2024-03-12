extends Marker3D

@export var disabled : bool = false
var occupied : bool = false
# Called when the node enters the scene tree for the first time.
func _enter_tree():
	hide()
	add_to_group("baseMarker")
	pass # Replace with function body.

