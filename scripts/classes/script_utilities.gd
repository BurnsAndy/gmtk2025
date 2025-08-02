extends Node
class_name ScriptUtilities

#Allegedly Godot does not have away to do this inherently, which is mind boggling
func int_to_str(in_int:int, seperator: String = ","):
	if seperator.length() > 1 || in_int < 1000 && in_int > -1000:
		return str(in_int)
	var rev_int_str: String = rev_str(str(abs(in_int)))
	var out_str: String = ""
	for i in range(rev_int_str.length()):
		out_str += rev_int_str[i]
		if i + 1 < rev_int_str.length() && (i + 1) % 3 == 0:
			out_str += seperator
	out_str = rev_str(out_str)
	if in_int < 0:
		out_str = "-" + out_str
	return out_str
	
#Reverses a string
func rev_str(in_str: String):
	var out_str: String
	for i in range(in_str.length()):
		out_str = in_str[i] + out_str
	return out_str
