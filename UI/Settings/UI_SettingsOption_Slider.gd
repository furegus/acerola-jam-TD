@tool
extends SettingsOption

@export var value : float = 0:
	set(v):
		value = v
		if !is_instance_valid($MarginContainer/HBoxContainer/FPSHBoxContainer):
			return
		$MarginContainer/HBoxContainer/FPSHBoxContainer/NumLabel.text = str(v)
		$MarginContainer/HBoxContainer/FPSHBoxContainer/Slider.value = (v)

@export var minValue : float = 0:
	set(v):
		minValue = v
		$MarginContainer/HBoxContainer/FPSHBoxContainer/Slider.min_value = minValue

@export var maxValue : float = 100:
	set(v):
		maxValue = v
		$MarginContainer/HBoxContainer/FPSHBoxContainer/Slider.max_value = v

@export var step : float = 1:
	set(v):
		step = v
		$MarginContainer/HBoxContainer/FPSHBoxContainer/Slider.step = v

var _updating : bool = false

func _ready():
	super._ready()
	
	if Engine.is_editor_hint():
		return
	maxValue = maxValue
	minValue = minValue
	step = step
	$MarginContainer/HBoxContainer/FPSHBoxContainer/NumLabel.text = str(value)
	$MarginContainer/HBoxContainer/FPSHBoxContainer/Slider.value = (value)

func UpdateSetting(val:float):
	if _updating:
		return
	_updating = true
	value = val
	if !code:
		_updating = false
		return
	code.new().execute(val)
	_updating = false


func _on_slider_value_changed(val:float):
	UpdateSetting(val)


func _on_num_label_text_submitted(new_text:String):
	value = float(new_text)
