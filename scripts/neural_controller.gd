extends Node2D

const WingScene = preload("res://components/wing.tscn")
var main_menu = load("res://main.tscn")

@export var wingPos = Vector2(500, 300)

var network = {}
var training = false

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


func _on_reset_nn_btn_pressed():
	network = NN.generateRandomNN(9, 6, 3)
	
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
	
	$Wing.position = wingPos
	$Wing.rotation_degrees = 0


func _on_train_nn_btn_pressed():
	training = not training
	$Mutate/Toggled.visible = training
	
	if not training:
		get_node("Wings/Wing").network = network
		get_node("Wings/Wing").position = wingPos
		get_node("Wings/Wing").rotation_degrees = 0


func _on_play_pause_pressed():
	Globals.paused = not Globals.paused
	$PlayPause2/play.visible = Globals.paused
	$PlayPause2/pause.visible = not Globals.paused


func _on_load_wing_button_pressed():
	Globals.loadWing()


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
	_on_reset_nn_btn_pressed()
	
	$NnDisplay.visible = Globals.toggleDetails
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
