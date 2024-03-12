extends Resource


func execute(value : float):
	var ID : int = AudioServer.get_bus_index("Music")
	
	value = lerp(- 40 , 0, value/100.0)
	if value == -40:
		AudioServer.set_bus_mute(ID, true)
	else:
		AudioServer.set_bus_mute(ID, false)
	
	AudioServer.set_bus_volume_db(ID, value)
