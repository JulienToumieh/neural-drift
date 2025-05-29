extends Node2D


var track1 = load("res://tracks/track1.tscn")
var track2 = load("res://tracks/track2.tscn")
var track3 = load("res://tracks/track3.tscn")

var level = 1
var levels = {
	1: "Level I",
	2: "Level II",
	3: "Level III",
}


func _process(delta):
	$BGLines.modulate.h = Globals.hue
	$BG.modulate.h = Globals.hue
	
	if Input.is_action_just_pressed("toggle_quality"):
		_on_low_q_mode_btn_pressed()

func updateLevel():
	$Controls/TrackLbl.text = levels.get(level)
	
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
	match level:
		1:
			get_tree().change_scene_to_packed(track1)
		2:
			get_tree().change_scene_to_packed(track2)
		3:
			get_tree().change_scene_to_packed(track3)


func _on_low_q_mode_btn_pressed():
	Globals.lowQualityMode = not Globals.lowQualityMode
	$WorldEnvironment.environment.glow_enabled = not Globals.lowQualityMode
	
	if Globals.lowQualityMode:
		$AnimationPlayer2.pause()
	else:
		$AnimationPlayer2.play("bg_move")
