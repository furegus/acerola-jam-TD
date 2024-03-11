extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func explode():
	$GPUParticles3D.restart()
	$GPUParticles3D2.restart()
	$GPUParticles3D3.restart()

func explode_with_rand_offset(offset_time: float = 0.4):
	await get_tree().create_timer(randf_range(0,offset_time)).timeout
	explode()
