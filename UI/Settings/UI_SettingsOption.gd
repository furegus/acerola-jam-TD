extends Control
class_name SettingsOption

#const HOVERAUDIO := preload("res://Assets/SFX/UI/sfx_ui_hover.wav")

@export var code: GDScript
@export var label : String = "Enable BoolName":
	set(v):
		if label == v:
			return
		label = v
		$MarginContainer/HBoxContainer/Label.text = v

@export var canGrabFocus : bool = true
@export var FOCUSBUTTON : NodePath:
	set(v):
		FOCUSBUTTON = v

var focusButton : Control

#@export var var_save_name : StringName
#@export var save_section : StringName

func _enter_tree():
	if Engine.is_editor_hint():
		return
	add_to_group("SettingsOption")
	#focus_entered.connect(_onHasFocus)
	#mouse_entered.connect(_onHasFocus)
	#$Button.pressed.connect(_onClicked)

func _ready():
	if Engine.is_editor_hint():
		return
	focusButton = get_node(FOCUSBUTTON)
	if !canGrabFocus or !is_instance_valid(focusButton):
		canGrabFocus = false
		$Button.hide()
		return

func SaveOption():
	pass

func LoadOption():
	pass

func UpdateSetting(val):
	pass

func _onHasFocus():
	get_tree().call_group("SettingsOption","LoseFocus")
	#MusicManager.UiTrack(HOVERAUDIO)
	$ColorRect.show()
	#if canGrabFocus:
		#focusButton.grab_focus()
	#$Button.grab_focus()

func LoseFocus():
	$ColorRect.hide()
	

func _onClicked():
	if is_instance_valid(focusButton):
		focusButton.grab_focus()
	
