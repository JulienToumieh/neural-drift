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


func flattenNetwork(network):
	var genome = []
	
	for i in range(network["input_to_hidden"].size()):
		for j in range(network["hidden_bias"].size()):
			genome.append(network["input_to_hidden"][i][j])
	
	for i in range(network["hidden_bias"].size()):
		genome.append(network["hidden_bias"][i])
	
	for i in range(network["hidden_to_output"].size()):
		for j in range(network["output_bias"].size()):
			genome.append(network["hidden_to_output"][i][j])

	for i in range(network["output_bias"].size()):
		genome.append(network["output_bias"][i])
	
	return genome

func unflattenGenome(genome, input, hidden, output):
	var index = 0
	
	var inputToHidden = []
	for i in range(input):
		var row = []
		for j in range(hidden):
			row.append(genome[index])
			index += 1
		
		inputToHidden.append(row)
	
	var hiddenBias = []
	for i in range(hidden):
		hiddenBias.append(genome[index])
		index += 1
	
	var hiddenToOutput = []
	for i in range(hidden):
		var row = []
		for j in range(output):
			row.append(genome[index])
			index += 1
		
		hiddenToOutput.append(row)
	
	var outputBias = []
	for i in range(output):
		outputBias.append(genome[index])
		index += 1
	
	return {
		"input_to_hidden": inputToHidden,
		"hidden_bias": hiddenBias,
		"hidden_to_output": hiddenToOutput,
		"output_bias": outputBias
	}


func mutateNetwork(parent, mutationRate := 0.02, mutationStrength := 0.5):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var genome = flattenNetwork(parent)
	for i in range(genome.size()):
		if rng.randf() < mutationRate:
			var gene = genome[i] + rng.randf_range(-mutationStrength, mutationStrength)
			genome[i] = clamp(gene, -1.0, 1.0)
	
	return unflattenGenome(genome, parent["input_to_hidden"].size(), parent["hidden_bias"].size(), parent["output_bias"].size())

func mixGenes(gene1, gene2, crossoverRate := 0.5, blendRate := 0.3, mutationRate := 0.02, mutationStrength := 0.5):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var gene = gene1
	if rng.randf() > crossoverRate:
		gene = gene2
	
	if rng.randf() < blendRate:
		var blend = rng.randf()
		gene = gene1 * blend + gene2 * (1.0 - blend)
	
	if rng.randf() < mutationRate:
		gene += rng.randf_range(-mutationStrength, mutationStrength)
	
	return clamp(gene, -1.0, 1.0)

func crossover(parent1, parent2, crossoverRate := 0.5, blendRate := 0.3, mutationRate := 0.02, mutationStrength := 0.5):
	var genome1 = flattenNetwork(parent1)
	var genome2 = flattenNetwork(parent2)
	
	var offspring = []
	
	for i in range(genome1.size()):
		offspring.append(mixGenes(genome1[i], genome2[i]))
	
	return unflattenGenome(offspring, parent1["input_to_hidden"].size(), parent1["hidden_bias"].size(), parent1["output_bias"].size())
