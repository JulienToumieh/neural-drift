extends CharacterBody2D

const speed = 30.0
var rotation_speed = 0.1
var friction = 0.96

@export var color = "#FFFFFF"

func _ready():
	changeColor(color)
	#$flame.visible = false

func _physics_process(delta):
	if Input.is_action_pressed("ui_up"):
		velocity += Vector2(0, -speed).rotated(rotation)
	if Input.is_action_pressed("ui_left"):
		rotation -= rotation_speed
		#velocity += Vector2(0, -SPEED * 0.02).rotated(rotation)
	if Input.is_action_pressed("ui_right"):
		rotation += rotation_speed
		#velocity += Vector2(0, -SPEED * 0.02).rotated(rotation)
		
	
	if ($BackRay1.is_colliding() or $BackRay2.is_colliding()) and Input.is_action_pressed("ui_up"):
		var wallThrust1 = 1 - global_position.distance_to($BackRay1.get_collision_point())/50
		var wallThrust2 = 1 - global_position.distance_to($BackRay2.get_collision_point())/50
		
		velocity += Vector2(0, -speed * (isPos(wallThrust1) + isPos(wallThrust2)) * 2).rotated(rotation)
		
	if Input.is_action_just_released("ui_up"):
		$flame.visible = false
	if Input.is_action_just_pressed("ui_up"):
		$flame.visible = true
		
	velocity *= friction

	move_and_slide()

func changeColor(col):
	$Wing.modulate = Color(col)
	$WingCore.modulate = Color(col)
	$PointLight2D.color = Color(col)

func isPos(val):
	if val > 0:
		return val
	return 0
