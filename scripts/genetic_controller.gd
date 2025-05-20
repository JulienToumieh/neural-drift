extends Node2D

const WingScene = preload("res://components/wing.tscn")

@export var wingPos = Vector2(500, 300)


func setNNDisp(ID):
	print("Disp set: " + str(ID))
	for wing in $Wings.get_children():
		if wing.ID == ID:
			wing.DisplayNN = true
		else:
			wing.DisplayNN = false

func _on_new_population_pressed():
	for child in $Wings.get_children():
		$Wings.remove_child(child)
		child.queue_free()
	
	for i in range(int($Population/Population.text)):
		var wing = WingScene.instantiate()
		wing.position = wingPos
		wing.ID = i
		$Wings.add_child(wing)


func _on_mutate_pressed():
	for child in $Wings.get_children():
		$Wings.remove_child(child)
		child.queue_free()
	
	for i in range(int($Population/Population.text)):
		var wing = WingScene.instantiate()
		wing.position = wingPos
		wing.network = GANN.mutateNetwork(Globals.parents[0], $Parameters/MutationRateSlider.value, $Parameters/MutationStrengthSlider.value)
		wing.ID = i
		$Wings.add_child(wing)
		


func _on_crossover_pressed():
	for child in $Wings.get_children():
		$Wings.remove_child(child)
		child.queue_free()
	
	for i in range(int($Population/Population.text)):
		var wing = WingScene.instantiate()
		wing.position = wingPos
		wing.network = GANN.crossover(Globals.parents[0], Globals.parents[1], $Parameters/CrossoverRateSlider.value ,$Parameters/CrossoverBlendSlider.value, $Parameters/MutationRateSlider.value, $Parameters/MutationStrengthSlider.value)
		wing.ID = i
		$Wings.add_child(wing)


func _on_play_pause_pressed():
	Globals.paused = not Globals.paused
	$PlayPause2/play.visible = Globals.paused
	$PlayPause2/pause.visible = not Globals.paused
