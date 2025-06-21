extends Node

var parents = []
var paused = false

var hue = 0.0
var toggleDetails = false

var NNDispID = -1

var data_path = "user:/"

var wingScores = []

var lowQualityMode = false


func _ready():
	for i in range(2):
		parents.append(GANN.generateRandomNN(5, 6, 3))
	
	while true:
		await get_tree().create_timer(0.1).timeout
		hue += 0.001

func addWing(network):
	parents.pop_back()
	parents.push_front(network)

func saveWing(network, wingname = "wing"):
	DirAccess.make_dir_absolute(data_path + "/Wings/")
	var save_file = FileAccess.open(data_path + "/Wings/" + wingname + ".wng", FileAccess.WRITE)
	
	var wing_data = {
		"network": network
	}
	
	save_file.store_line(JSON.stringify(wing_data))
	save_file.close()

func loadWing(wingname = "wing"):
	var load_file = FileAccess.open(data_path + "/Wings/" + wingname + ".wng", FileAccess.READ)
	
	var json_data = load_file.get_line()
	load_file.close() 
	var json = JSON.new()
	var _parse_result = json.parse(json_data)

	var wing_data = json.data
	var network = wing_data["network"]
	
	addWing(network)


func resetScores(count):
	wingScores.clear()
	for i in range(count):
		wingScores.append(0) 


func saveTrainingData(inputs, outputs):
	DirAccess.make_dir_absolute(data_path + "/Training Data/")
	var save_file = FileAccess.open(data_path + "/Training Data/TrainingData.td", FileAccess.WRITE)
	
	var input_data = {
		"inputs": inputs,
		"outputs": outputs
	}
	
	save_file.store_line(JSON.stringify(input_data))
	save_file.close()

func loadTrainingData():
	var load_file = FileAccess.open(data_path + "/Training Data/TrainingData.td", FileAccess.READ)
	
	var json_data = load_file.get_line()
	load_file.close() 
	var json = JSON.new()
	var _parse_result = json.parse(json_data)

	var training_data = json.data
	var inputs = training_data["inputs"]
	var outputs = training_data["outputs"]
	
	return training_data


func loadBuiltInTrainingData():
	var load_file = FileAccess.open("res://TrainingData.td", FileAccess.READ)
	
	var json_data = load_file.get_line()
	load_file.close() 
	var json = JSON.new()
	var _parse_result = json.parse(json_data)

	var training_data = json.data
	var inputs = training_data["inputs"]
	var outputs = training_data["outputs"]
	
	return training_data

func _process(delta):
	if Input.is_key_pressed(KEY_F11):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

		
