@tool
extends Button

@export var class_ID : Combatant:
	set(v):
		class_ID = v
		if Engine.is_editor_hint():
			if !class_ID:
				#$TextureRect.texture = null
				icon = null
			icon = class_ID.sprite
			#$TextureRect.texture = class_ID.sprite
@export var _combatant : PackedScene
#var combatant : Node3D

var toolTipInstance : Panel

@onready var tool_tip: PackedScene = preload("res://UI/stat_panel.tscn")

func _ready():
	if !class_ID:
		return
	class_ID = class_ID.duplicate()
	icon = class_ID.sprite
	#$TextureRect.texture = class_ID.sprite
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_up():
	Engine.time_scale = 1
	SignalManager.combatant_placement_end.emit()
	MusicManager.DisableBandpass()
	

func _on_button_down():
	if !class_ID:
		return
	Engine.time_scale = 0.5
	var comb : Node3D = _combatant.instantiate()
	comb.class_ID = class_ID
	SignalManager.combatant_placement_start.emit(comb)
	MusicManager.EnableBandpass()
	


func _on_mouse_entered():
	if !tool_tip:
		return
	await get_tree().create_timer(0.3).timeout
	if !is_hovered():
		return
	
	toolTipInstance = tool_tip.instantiate()
	toolTipInstance.class_ID = class_ID
	#print(toolTipInstance)
	toolTipInstance.configure()
	# Set tooltip position
	var canvas = get_parent().get_global_transform_with_canvas().origin  - Vector2(0, 144)
	var pos = canvas
	pos.x = get_global_mouse_position().x - toolTipInstance.size.x / 2.0
	#pos.x = clampf(pos.x, canvas.x, get_parent().size.x - toolTipInstance.size.x)
	toolTipInstance.position = (pos)
	
	GameManager.ui.add_child(toolTipInstance)
	toolTipInstance.show()


func _on_mouse_exited():
	var nodes: Array = get_tree().get_nodes_in_group("tooltip")
	if nodes.size() > 0:
		for x in nodes:
			x.free()
