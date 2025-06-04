extends Node2D

const WingScene = preload("res://components/wing.tscn")
var main_menu = load("res://main.tscn")

@export var wingPos = Vector2(500, 300)

var network = {}
var training = false

var trainingInputs = []
var trainingOutputs = []

var autoGen = false

func setNNDisp(ID):
	print("Disp set: " + str(ID))
	for wing in $Wings.get_children():
		if wing.ID == ID:
			wing.DisplayNN = true
		else:
			wing.DisplayNN = false

func trainNN(input, output):
	if training:
		network = NN.trainNN(network, input, output, $Parameters/EpochsSlider.value, $Parameters/LearningRateSlider.value)
		
		trainingInputs.append(input)
		trainingOutputs.append(output)

func _on_reset_nn_btn_pressed():
	network = NN.generateRandomNN(9, 6, 3)
	
	trainingInputs.clear()
	trainingOutputs.clear()
	
	$AnimationPlayer.play("pulse_bg")
	
	for child in $Wings.get_children():
		$Wings.remove_child(child)
		child.queue_free()
	
	var wing = WingScene.instantiate()
	wing.position = wingPos
	wing.ID = -2
	wing.get_node("PointLight2D").enabled = not Globals.lowQualityMode
	wing.invincible = true
	wing.trainingMode = true
	$Wings.add_child(wing)
	
	setNNDisp(-2)
	
	$Wing.position = wingPos
	$Wing.rotation_degrees = 0


func _on_train_nn_btn_pressed():
	training = not training
	$Mutate/Toggled.visible = training
	
	if not training:
		get_node("Wings/Wing").network = network
		get_node("Wings/Wing").position = wingPos
		get_node("Wings/Wing").rotation_degrees = 0
		
		Globals.saveTrainingData(trainingInputs, trainingOutputs)


func _on_play_pause_pressed():
	Globals.paused = not Globals.paused
	$PlayPause2/play.visible = Globals.paused
	$PlayPause2/pause.visible = not Globals.paused


func _on_load_wing_button_pressed():
	Globals.loadWing()
	
	for child in $Wings.get_children():
		$Wings.remove_child(child)
		child.queue_free()
		
	var wing = WingScene.instantiate()
	wing.position = wingPos
	wing.ID = -2
	wing.get_node("PointLight2D").enabled = not Globals.lowQualityMode
	wing.invincible = true
	wing.trainingMode = true
	wing.network = Globals.parents[0]
	$Wings.add_child(wing)
	
	setNNDisp(-2)


func _process(delta):
	$BGLines.modulate.h = Globals.hue
	$BG.modulate.h = Globals.hue
	$LossGraph/LossGraph.modulate.h = Globals.hue
	
	if Input.is_action_just_pressed("toggle_details"):
		Globals.toggleDetails = not Globals.toggleDetails
		$NnDisplay.visible = Globals.toggleDetails
		$LossGraph.visible = Globals.toggleDetails
	
	if Input.is_action_just_pressed("toggle_quality"):
		Globals.lowQualityMode = not Globals.lowQualityMode
		$WorldEnvironment.environment.glow_enabled = not Globals.lowQualityMode
		
		for child in $Wings.get_children():
			if child.get_node("PointLight2D"):
				child.get_node("PointLight2D").enabled = not Globals.lowQualityMode
		
		if Globals.lowQualityMode:
			$AnimationPlayer2.pause()
		else:
			$AnimationPlayer2.play("bg_move")



func _ready():
	_on_reset_nn_btn_pressed()
	
	$NnDisplay.visible = Globals.toggleDetails
	$LossGraph.visible = Globals.toggleDetails
	$WorldEnvironment.environment.glow_enabled = not Globals.lowQualityMode
	
	if Globals.lowQualityMode:
		$AnimationPlayer2.pause()
	else:
		$AnimationPlayer2.play("bg_move")
		
	$Wing.position = wingPos



func _on_exit_btn_pressed():
	get_tree().change_scene_to_packed(main_menu)


func _on_show_details_btn_pressed():
	Globals.toggleDetails = not Globals.toggleDetails
	$NnDisplay.visible = Globals.toggleDetails
	$LossGraph.visible = Globals.toggleDetails


func _on_train_from_data_btn_pressed():
	var trainingData = Globals.loadTrainingData()
	trainFromData(trainingData)

func _on_train_from_built_in_data_btn_pressed():
	var trainingData = Globals.loadBuiltInTrainingData()
	trainFromData(trainingData)


func trainFromData(trainingData):
	training = true
	$TrainingPopup.visible = true
	await get_tree().create_timer(0.1).timeout
	
	$LossGraph/LossGraph.clear_points()
	
	network = NN.generateRandomNN(9, 6, 3)
	
	var inputs = trainingData["inputs"]
	var outputs = trainingData["outputs"]
	
	var lossGraphPoints = []
	var total_loss = 0.0
	for k in range(inputs.size()):
		var preds = NN.forwardPass(network, inputs[k])
		total_loss += NN.mean_squared_error(preds, outputs[k])
	total_loss /= inputs.size()
	
	print("Epoch: 0 - Loss: " + str(total_loss))
	
	lossGraphPoints.append(Vector2(0, -total_loss*1000))
	
	for i in range(1, $Parameters/EpochsSlider.value + 1):
		
		for j in range(outputs.size()):
			network = NN.trainSingleEpoch(network, inputs[j], outputs[j], $Parameters/LearningRateSlider.value)
			
			if i == 1:
				trainingInputs.append(inputs[j])
				trainingOutputs.append(outputs[j])
			
		#if i % 10 == 0:
		total_loss = 0.0
		for k in range(inputs.size()):
			var preds = NN.forwardPass(network, inputs[k])
			total_loss += NN.mean_squared_error(preds, outputs[k])
		total_loss /= inputs.size()
		
		print("Epoch: " + str(i) + " - Loss: " + str(total_loss))
		#print(str(Globals.epochs[i]) + " - " + str(Globals.losses[i]))
		
		lossGraphPoints.append(Vector2(i*3, -total_loss*1000))


	var x_values = []
	var y_values = []

	for point in lossGraphPoints:
		x_values.append(point.x)
		y_values.append(point.y)

	var min_x = x_values.min()
	var max_x = x_values.max()
	var min_y = y_values.min()
	var max_y = y_values.max()

	if max_x == min_x:
		max_x += 0.0001
	if max_y == min_y:
		max_y += 0.0001

	for i in range(lossGraphPoints.size()):
		var point = lossGraphPoints[i]

		var normalized_x = (point.x - min_x) / (max_x - min_x)
		var normalized_y = (point.y - min_y) / (max_y - min_y)

		lossGraphPoints[i] = Vector2(normalized_x, normalized_y)


	for point in lossGraphPoints:
		$LossGraph/LossGraph.add_point(Vector2(point.x * 200, point.y * 200 - 200))


	for child in $Wings.get_children():
		$Wings.remove_child(child)
		child.queue_free()
	
	var wing = WingScene.instantiate()
	wing.position = wingPos
	wing.ID = -2
	wing.get_node("PointLight2D").enabled = not Globals.lowQualityMode
	wing.invincible = true
	wing.trainingMode = true
	wing.network = network
	$Wings.add_child(wing)
	
	setNNDisp(-2)
	
	$TrainingPopup.visible = false
	training = false
