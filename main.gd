extends Node2D


var track1 = load("res://tracks/track1.tscn")
var track2 = load("res://tracks/track2.tscn")
var track3 = load("res://tracks/track3.tscn")

var track1neural = load("res://tracks/track1_neural.tscn")
var track2neural = load("res://tracks/track2_neural.tscn")
var track3neural = load("res://tracks/track3_neural.tscn")

var level = 1
var levels = {
	1: "Level I",
	2: "Level II",
	3: "Level III"
}

var mode = 1
var modes = {
	1: "Genetic",
	2: "Neural"
}

func _process(delta):
	$BGLines.modulate.h = Globals.hue
	$BG.modulate.h = Globals.hue
	
	if Input.is_action_just_pressed("toggle_quality"):
		_on_low_q_mode_btn_pressed()

func updateLevel():
	$Controls/TrackLbl.text = levels.get(level)
	$Controls/ModeLbl.text = modes.get(mode)
	
	$TrackImages/Track1.visible = false
	$TrackImages/Track2.visible = false
	$TrackImages/Track3.visible = false
	match level:
		1:
			$TrackImages/Track1.visible = true
		2:
			$TrackImages/Track2.visible = true
		3:
			$TrackImages/Track3.visible = true

func _on_next_track_btn_pressed():
	if level != 3:
		level += 1
		updateLevel()


func _on_prev_track_btn_pressed():
	if level != 1:
		level -= 1
		updateLevel()


func _on_start_btn_pressed():
	match mode:
		1:
			match level:
				1:
					get_tree().change_scene_to_packed(track1)
				2:
					get_tree().change_scene_to_packed(track2)
				3:
					get_tree().change_scene_to_packed(track3)
		2:
			match level:
				1:
					get_tree().change_scene_to_packed(track1neural)
				2:
					get_tree().change_scene_to_packed(track2neural)
				3:
					get_tree().change_scene_to_packed(track3neural)


func _on_low_q_mode_btn_pressed():
	Globals.lowQualityMode = not Globals.lowQualityMode
	$WorldEnvironment.environment.glow_enabled = not Globals.lowQualityMode
	
	if Globals.lowQualityMode:
		$AnimationPlayer2.pause()
	else:
		$AnimationPlayer2.play("bg_move")


func _on_prev_mode_btn_pressed():
	if mode != 1:
		mode -= 1
		updateLevel()


func _on_next_mode_btn_pressed():
	if mode != 2:
		mode += 1
		updateLevel()
