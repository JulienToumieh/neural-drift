extends Node


func generateRandomNN(input, hidden, output) -> Dictionary:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var inputToHidden = []
	for i in range(input):
		var row = []
		for j in range(hidden):
			row.append(rng.randf_range(-1.0, 1.0))
		inputToHidden.append(row)
	
	var hiddenBias = []
	for i in range(hidden):
		hiddenBias.append(rng.randf_range(-1.0, 1.0))
	
	
	var hiddenToOutput = []
	for i in range(hidden):
		var row = []
		for j in range(output):
			row.append(rng.randf_range(-1.0, 1.0))
		hiddenToOutput.append(row)
		
	var outputBias = []
	for i in range(output):
		outputBias.append(rng.randf_range(-1.0, 1.0))
	
	return {
		"input_to_hidden": inputToHidden,
		"hidden_bias": hiddenBias,
		"hidden_to_output": hiddenToOutput,
		"output_bias": outputBias
	}


func forwardPass(network, input):
	var hiddenOut = []
	for i in range(network["hidden_bias"].size()):
		var sum = 0.0
		
		for j in range(network["input_to_hidden"].size()):
			sum += input[j] * network["input_to_hidden"][j][i]
		
		hiddenOut.append(sigmoid(sum))
	
	
	var outputOut = []
	for i in range(network["output_bias"].size()):
		var sum = 0.0
		
		for j in range(network["hidden_to_output"].size()):
			sum += hiddenOut[j] * network["hidden_to_output"][j][i]
		
		outputOut.append(sigmoid(sum))
	
	return outputOut

func sigmoid(x: float) -> float:
	return 1.0 / (1.0 + exp(-x))

func d_sigmoid(x: float) -> float:
	var s = sigmoid(x)
	return s * (1 - s)


func backPropagate(network, x, y, learning_rate := 0.01):
	var z1 = []
	var a1 = []
	for i in range(network["hidden_bias"].size()):
		var sum = 0.0
		
		for j in range(network["input_to_hidden"].size()):
			sum += x[j] * network["input_to_hidden"][j][i]
		
		z1.append(sum + network["hidden_bias"][i])
		a1.append(sigmoid(z1[i]))
	
	var z2 = []
	var a2 = []
	for i in range(network["output_bias"].size()):
		var sum = 0.0
		
		for j in range(network["hidden_to_output"].size()):
			sum += a1[j] * network["hidden_to_output"][j][i]
		
		z2.append(sum + network["output_bias"][i])
		a2.append(sigmoid(z2[i]))

	var delta2 = []
	for i in range(a2.size()):
		var error = a2[i] - y[i]
		delta2.append(error * d_sigmoid(z2[i]))
		
	for i in range(network["hidden_to_output"].size()):
		for j in range(network["hidden_to_output"][i].size()):
			var grad = delta2[j] * a1[i]
			network["hidden_to_output"][i][j] -= learning_rate * grad
	
	for i in range(network["output_bias"].size()):
		network["output_bias"][i] -= learning_rate * delta2[i]
	
	var delta1 = []
	for i in range(a1.size()):
		var sum = 0.0
		
		for j in range(delta2.size()):
			sum += network["hidden_to_output"][i][j] * delta2[j]
		delta1.append(sum * d_sigmoid(z1[i]))
		
	for i in range(network["input_to_hidden"].size()):
		for j in range(network["input_to_hidden"][i].size()):
			var grad = delta1[j] * x[i]
			network["input_to_hidden"][i][j] -= learning_rate * grad
	
	for i in range(network["hidden_bias"].size()):
		network["hidden_bias"][i] -= learning_rate * delta1[i]
	
	return network


func mean_squared_error(a: Array, b: Array) -> float:
	var sum = 0.0
	
	for i in range(a.size()):
		var diff = a[i] - b[i]
		sum += diff * diff
	
	return sum / a.size()

func trainNN(network, x, y, epochs := 100, learning_rate := 0.01):
	for epoch in range(epochs):
		network = backPropagate(network, x, y, learning_rate)
		if epoch % 10 == 0:
			var preds = forwardPass(network, x)
			var loss = mean_squared_error(preds, y)
			#print("Epoch: " + str(epoch) + " Loss: " + str(loss))
	
	return network


func trainSingleEpoch(network, x, y, learning_rate := 0.01):
	network = backPropagate(network, x, y, learning_rate)
	return network
