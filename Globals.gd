extends Node

var parents = []
var paused = false

var hue = 0.0

var NNDispID = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(5):
		parents.append(GANN.generateRandomNN(5, 6, 3))

func addWing(network):
	parents.pop_back()
	parents.push_front(network)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
