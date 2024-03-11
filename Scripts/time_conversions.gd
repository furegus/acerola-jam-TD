extends RefCounted
class_name TimeConversion

static func ms_to_string(milisecs):
	milisecs = int(milisecs)
	var s2 = floor(milisecs/100)
	var ms2 = milisecs % 100
	var m2 = floor(s2/60.0)
	s2 = s2 % 60
	var string : String = "%02d" % m2 + " : " + "%02d" %  s2 + " : " +"%02d" %  ms2
#	print(string)
	return string

static func s_to_string(secs):
	#secs = int(secs)
	var s2: int = floor(secs)
	var m2 : int = floor(s2/60.0)
	s2 = s2 % 60
	var string : String = "%02d" % m2 + " : " + "%02d" %  s2
#	print(string)
	return string
