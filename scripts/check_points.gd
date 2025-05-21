extends Node2D


func _ready():
	for check in get_children():
		if check is Area2D:
			check.body_entered.connect(_on_area_body_entered)


func _on_area_body_entered(body):
	if body is CharacterBody2D:
		body.score += 1
