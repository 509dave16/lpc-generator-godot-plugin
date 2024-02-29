extends Node
class_name JSONLoader

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_json_file(file_path: String) -> Dictionary:
	var empty_dictionary: Dictionary = {}
	if FileAccess.file_exists(file_path):
		var data_file = FileAccess.open(file_path, FileAccess.READ)
		var parsed_result = JSON.parse_string(data_file.get_as_text())
		if parsed_result is Dictionary:
			return parsed_result
		else:
			print("Failed to parse file " + file_path)
			return empty_dictionary
	else:
		print("File " + file_path + " does not exist")
	return empty_dictionary
	
