class_name Enhancements

static func check_and_erase(array: Array) -> Array:
	for x in array:
		if !is_instance_valid(x):
			array.erase(x)
	
	return array
