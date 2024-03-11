extends Panel

# === Constants === #
const CHAR_PROG_UNFILLED = "▢"
const CHAR_PROG_FILLED = "■"
# === Export variables === #
@export var class_ID : Combatant
		


func _ready():
	configure()

func configure():
	if !class_ID:
		return
	add_to_group("tooltip")
	$MarginContainer/VBoxContainer/Name.text = class_ID.name
	$MarginContainer/VBoxContainer/CostTab/cost.text = "$"+str(class_ID.cost)
	$MarginContainer/VBoxContainer/Description.text = class_ID.description
	#$MarginContainer/VBoxContainer/DmgTab/damage.text = stat_calc(class_ID.damage)
	#$MarginContainer/VBoxContainer/SpdTab/speed.text = stat_calc(class_ID.speed)

func stat_calc(statVal:int) -> String:
	statVal = clampi(statVal, 0, 6)
	var text: String = "▢▢▢▢▢▢"
	match statVal:
		1:
			text = "■▢▢▢▢▢"
		2:
			text = "■■▢▢▢▢"
		3:
			text = "■■■▢▢▢"
		4:
			text = "■■■■▢▢"
		5:
			text = "■■■■■▢"
		6:
			text = "■■■■■■"
	
	return text
