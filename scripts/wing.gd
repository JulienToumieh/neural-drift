extends CharacterBody2D

const speed = 18.0
var rotation_speed = 0.1
var friction = 0.96

@export var color = "#FFFFFF"
@export var playable = false
@export var network = {}

func _ready():
	changeColor(color)
	if not playable and network.is_empty():
		network = GANN.generateRandomNN(5, 6, 3)

func _physics_process(delta):
	if playable:
		if Input.is_action_pressed("ui_up"):
			velocity += Vector2(0, -speed).rotated(rotation)
		if Input.is_action_pressed("ui_left"):
			rotation -= rotation_speed
			#velocity += Vector2(0, -SPEED * 0.02).rotated(rotation)
		if Input.is_action_pressed("ui_right"):
			rotation += rotation_speed
			#velocity += Vector2(0, -SPEED * 0.02).rotated(rotation)
		
		if Input.is_action_just_released("ui_up"):
			$flame.visible = false
		if Input.is_action_just_pressed("ui_up"):
			$flame.visible = true
		
		if ($BackRay1.is_colliding() or $BackRay2.is_colliding()) and Input.is_action_pressed("ui_up"):
			var wallThrust1 = 1 - global_position.distance_to($BackRay1.get_collision_point())/50
			var wallThrust2 = 1 - global_position.distance_to($BackRay2.get_collision_point())/50
			velocity += Vector2(0, -speed * (isPos(wallThrust1) + isPos(wallThrust2)) * 2).rotated(rotation)
	else:
		var distance1 = global_position.distance_to($RayCast1.get_collision_point())/320
		var distance2 = global_position.distance_to($RayCast2.get_collision_point())/320
		var distance3 = global_position.distance_to($RayCast3.get_collision_point())/320
		var distance4 = global_position.distance_to($RayCast4.get_collision_point())/320
		var distance5 = global_position.distance_to($RayCast5.get_collision_point())/320
		
		var inputs = [distance1, distance2, distance3, distance4, distance5]
		
		var output = GANN.forwardPass(network, inputs)
		
		if output[0] > 0.5:
			velocity += Vector2(0, -speed).rotated(rotation)
			$flame.visible = true
		else:
			$flame.visible = false
		if output[1] > 0.5:
			rotation -= rotation_speed
		if output[2] > 0.5:
			rotation += rotation_speed
		
		if ($BackRay1.is_colliding() or $BackRay2.is_colliding()) and output[0] > 0.5:
			var wallThrust1 = 1 - global_position.distance_to($BackRay1.get_collision_point())/50
			var wallThrust2 = 1 - global_position.distance_to($BackRay2.get_collision_point())/50
			velocity += Vector2(0, -speed * (isPos(wallThrust1) + isPos(wallThrust2)) * 2).rotated(rotation)
	
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
