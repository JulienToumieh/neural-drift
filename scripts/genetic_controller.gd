extends Node2D

const WingScene = preload("res://components/wing.tscn")
var main_menu = load("res://main.tscn")

@export var wingPos = Vector2(500, 300)

var autoGen = false

func setNNDisp(ID):
	print("Disp set: " + str(ID))
	for wing in $Wings.get_children():
		if wing.ID == ID:
			wing.DisplayNN = true
		else:
			wing.DisplayNN = false

func _on_new_population_pressed():
	Globals.resetScores(int($Population/Population.text))
	
	$AnimationPlayer.play("pulse_bg")
	
	for child in $Wings.get_children():
		$Wings.remove_child(child)
		child.queue_free()
	
	for i in range(int($Population/Population.text)):
		var wing = WingScene.instantiate()
		wing.position = wingPos
		wing.ID = i
		wing.get_node("PointLight2D").enabled = not Globals.lowQualityMode
		$Wings.add_child(wing)


func _on_mutate_pressed():
	Globals.resetScores(int($Population/Population.text))
	
	$AnimationPlayer.play("pulse_bg")
	
	for child in $Wings.get_children():
		$Wings.remove_child(child)
		child.queue_free()
		
	
	for i in range(2):
		var wing = WingScene.instantiate()
		wing.position = wingPos
		wing.network = Globals.parents[i]
		wing.ID = (int($Population/Population.text) - 2) + i
		wing.isParent = true
		wing.get_node("PointLight2D").enabled = not Globals.lowQualityMode
		$Wings.add_child(wing)
	
	for i in range(int($Population/Population.text) - 2):
		var wing = WingScene.instantiate()
		wing.position = wingPos
		wing.network = GANN.mutateNetwork(Globals.parents[0], $Parameters/MutationRateSlider.value, $Parameters/MutationStrengthSlider.value)
		wing.ID = i
		wing.get_node("PointLight2D").enabled = not Globals.lowQualityMode
		$Wings.add_child(wing)
		


func _on_crossover_pressed():
	Globals.resetScores(int($Population/Population.text))
	
	$AnimationPlayer.play("pulse_bg")
	
	for child in $Wings.get_children():
		$Wings.remove_child(child)
		child.queue_free()
	
	for i in range(2):
		var wing = WingScene.instantiate()
		wing.position = wingPos
		wing.network = Globals.parents[i]
		wing.ID = (int($Population/Population.text) - 2) + i
		wing.isParent = true
		wing.get_node("PointLight2D").enabled = not Globals.lowQualityMode
		$Wings.add_child(wing)
	
	for i in range(int($Population/Population.text)):
		var wing = WingScene.instantiate()
		wing.position = wingPos
		wing.network = GANN.crossover(Globals.parents[0], Globals.parents[1], $Parameters/CrossoverRateSlider.value ,$Parameters/CrossoverBlendSlider.value, $Parameters/MutationRateSlider.value, $Parameters/MutationStrengthSlider.value)
		wing.ID = i
		wing.get_node("PointLight2D").enabled = not Globals.lowQualityMode
		$Wings.add_child(wing)


func _on_play_pause_pressed():
	Globals.paused = not Globals.paused
	$PlayPause2/play.visible = Globals.paused
	$PlayPause2/pause.visible = not Globals.paused


func _on_load_wing_button_pressed():
	Globals.loadWing()

func _on_auto_gen_button_toggled(toggled_on):
	autoGen = toggled_on
	if autoGen:
		startGen()

func findHighestScore():
	var scores = Globals.wingScores.duplicate(true)
	
	var highestScore = 0
	var highestID = 0
	
	for i in range(scores.size()):
		if scores[i] > highestScore:
			highestScore = scores[i]
			highestID = i
	
	return highestID

func selectHighestScoreWing():
	var highestID = findHighestScore()
	
	var network = []
	
	print("Highest Score: " + str(highestID))
	
	for child in $Wings.get_children():
		if child.ID == highestID:
			network = child.network.duplicate(true)
	
	Globals.addWing(network)

var prevScores = []

func startGen():
	$GenTimer.start()
	_on_mutate_pressed()
	
	prevScores = Globals.wingScores.duplicate(true)
	$CheckTimer.start()


func _on_gen_timer_timeout():
	if autoGen:
		selectHighestScoreWing()
		startGen()


func _on_check_timer_timeout():
	if autoGen:
		if prevScores == Globals.wingScores:
			selectHighestScoreWing()
			startGen()
		else:
			prevScores = Globals.wingScores.duplicate(true)
			$CheckTimer.start()

func _process(delta):
	$BGLines.modulate.h = Globals.hue
	$BG.modulate.h = Globals.hue
	
	if Input.is_action_just_pressed("toggle_details"):
		Globals.toggleDetails = not Globals.toggleDetails
		$NnDisplay.visible = Globals.toggleDetails
	
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
	$NnDisplay.visible = Globals.toggleDetails
	$WorldEnvironment.environment.glow_enabled = not Globals.lowQualityMode
	
	if Globals.lowQualityMode:
		$AnimationPlayer2.pause()
	else:
		$AnimationPlayer2.play("bg_move")



func _on_exit_btn_pressed():
	get_tree().change_scene_to_packed(main_menu)


func _on_show_details_btn_pressed():
	Globals.toggleDetails = not Globals.toggleDetails
	$NnDisplay.visible = Globals.toggleDetails
