extends Node

var parents = []
var paused = false

var hue = 0.0
var toggleDetails = false

var NNDispID = -1

var data_path = "user:/"

var wingScores = []

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


func resetScores(count):
	wingScores.clear()
	for i in range(count):
		wingScores.append(0) 


func loadWing(wingname = "wing"):
	var load_file = FileAccess.open(data_path + "/Wings/" + wingname + ".wng", FileAccess.READ)
	
	var json_data = load_file.get_line()
	load_file.close() 
	var json = JSON.new()
	var _parse_result = json.parse(json_data)

	var wing_data = json.data
	var network = wing_data["network"]
	
	addWing(network)
