extends Node2D

@export var network = {}
var layers = [0, 0, 0] 

func _ready():
	network = GANN.generateRandomNN(5, 8, 3)
	layers = [network["input_to_hidden"].size(), network["hidden_bias"].size(), network["output_bias"].size()]
	
	for i in range(layers.size()):
		var layer = Node2D.new()
		layer.name = "Layer" + str(i + 1)
		add_child(layer)
		
		for j in range(layers[i]):
			var sprite = Sprite2D.new()
			sprite.texture = load("res://assets/circle.png")
			
			var centerBias = 0
			if i == 0:
				centerBias = 1.5
			elif i == 2:
				centerBias = 2.5
			
			sprite.position = Vector2(90 * i, (50 * j) + centerBias * 50)
			sprite.scale = Vector2(0.1, 0.1)
			sprite.name = "Neuron" + str(j + 1)
			sprite.z_index = 1
			layer.add_child(sprite)
	
	for i in range(layers.size() - 1):
		var layer1 = get_node("Layer" + str(i + 1))
		var layer2 = get_node("Layer" + str(i + 2))
		
		var connections = Node2D.new()
		connections.name = "Connections"
		layer1.add_child(connections)
		
		for j in range(layers[i + 1]):
			var neuron1 = layer2.get_node("Neuron" + str(j + 1))
			var NLC = Node2D.new()
			
			NLC.name = "NextNeuron" + str(j + 1)
			connections.add_child(NLC)
			
			for k in range(layers[i]):
				var neuron2 = layer1.get_node("Neuron" + str(k + 1))
				
				var line = Line2D.new()
				line.width = 2
				line.default_color = Color(1, 1, 0) 
				line.points = [neuron1.position, neuron2.position] 
				line.name = "Line" + str(k + 1)
				NLC.add_child(line)
				
	
	forwardPass(network, [0.2, 0.0, 0.8, 0.5, 1.0])



func forwardPass(network, input):
	
	var layer1 = get_node("Layer1")
	var layer2 = get_node("Layer2")
	var layer3 = get_node("Layer3")
	
	for i in range(input.size()):
		layer1.get_node("Neuron" + str(i + 1)).modulate.a = input[i]
	
	
	
	var hiddenOut = []
	for i in range(network["hidden_bias"].size()):
		var sum = 0.0
		
		var NLC = layer1.get_node("Connections/NextNeuron" + str(i + 1))
		
		for j in range(network["input_to_hidden"].size()):
			sum += input[j] * network["input_to_hidden"][j][i]
			NLC.get_node("Line" + str(j + 1)).modulate.a = input[j] * network["input_to_hidden"][j][i]
		
		hiddenOut.append(sigmoid(sum))
	
	for i in range(hiddenOut.size()):
		layer2.get_node("Neuron" + str(i + 1)).modulate.a = hiddenOut[i]
	
	
	
	var outputOut = []
	for i in range(network["output_bias"].size()):
		var sum = 0.0
		
		var NLC = layer2.get_node("Connections/NextNeuron" + str(i + 1))
		
		for j in range(network["hidden_to_output"].size()):
			sum += hiddenOut[j] * network["hidden_to_output"][j][i]
			NLC.get_node("Line" + str(j + 1)).modulate.a = hiddenOut[j] * network["hidden_to_output"][j][i]
		
		outputOut.append(sigmoid(sum))
	
	for i in range(outputOut.size()):
		layer3.get_node("Neuron" + str(i + 1)).modulate.a = outputOut[i]
	

func sigmoid(x: float) -> float:
	return 1.0 / (1.0 + exp(-x))
