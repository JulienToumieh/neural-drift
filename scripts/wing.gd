extends CharacterBody2D

const speed = 22.0
var rotation_speed = 0.1
var friction = 0.9
var wallThrust = 2.5

var deactivated = false
var afterdeath = 20.0

var score = 0

@export var isParent = false
@export var color = Color("#FFFFFF")
@export var playable = false
@export var network = {}
@export var ID = -1
@export var trainer = false
@export var trainingMode = false
@export var invincible = false

var DisplayNN = false

var waiting = false

func _ready():
	changeColor(color)
	if trainingMode:
		$RayCast6.enabled = true
		$RayCast7.enabled = true
		$RayCast8.enabled = true
		$RayCast9.enabled = true
		
	if not playable:
		changeColor(generate_light_vibrant_color())
		
		if isParent:
			$WingCore.visible = false
		

			
		if network.is_empty():
			if trainingMode:
				network = GANN.generateRandomNN(9, 6, 3)
			else:
				network = GANN.generateRandomNN(5, 6, 3)
			

func generate_light_vibrant_color() -> Color:
	var r = randf_range(0.4, 1.0)
	var g = randf_range(0.4, 1.0)  
	var b = randf_range(0.4, 1.0) 
	
	return Color(r, g, b)


func _physics_process(delta):
	if playable and not deactivated:
		var controls = [0, 0, 0]
		
		if Input.is_action_pressed("ui_up"):
			velocity += Vector2(0, -speed).rotated(rotation)
			controls[0] = 1
		
		if Input.is_action_pressed("ui_left"):
			rotation -= rotation_speed
			controls[1] = 1
			#velocity += Vector2(0, -SPEED * 0.02).rotated(rotation)
		
		if Input.is_action_pressed("ui_right"):
			rotation += rotation_speed
			controls[2] = 1
			#velocity += Vector2(0, -SPEED * 0.02).rotated(rotation)
		
		if Input.is_action_pressed("ui_down"):
			velocity += Vector2(0, speed).rotated(rotation)
		
		if Input.is_action_just_pressed("ui_up"):
			$flame.visible = true
		if Input.is_action_just_released("ui_up"):
			$flame.visible = false

		
		if ($BackRay1.is_colliding() or $BackRay2.is_colliding()) and Input.is_action_pressed("ui_up"):
			var wallThrust1 = 1 - global_position.distance_to($BackRay1.get_collision_point())/50
			var wallThrust2 = 1 - global_position.distance_to($BackRay2.get_collision_point())/50
			velocity += Vector2(0, -speed * (isPos(wallThrust1) + isPos(wallThrust2)) * wallThrust).rotated(rotation)
			
		if trainer:
			var distance1 = global_position.distance_to($RayCast1.get_collision_point())/320
			var distance2 = global_position.distance_to($RayCast2.get_collision_point())/320
			var distance3 = global_position.distance_to($RayCast3.get_collision_point())/320
			var distance4 = global_position.distance_to($RayCast4.get_collision_point())/320
			var distance5 = global_position.distance_to($RayCast5.get_collision_point())/320
			var distance6 = global_position.distance_to($RayCast6.get_collision_point())/320
			var distance7 = global_position.distance_to($RayCast7.get_collision_point())/320
			var distance8 = global_position.distance_to($RayCast8.get_collision_point())/320
			var distance9 = global_position.distance_to($RayCast9.get_collision_point())/320
			
			var inputs = [distance1, distance2, distance3, distance4, distance5, distance6, distance7, distance8, distance9]
			
			if (controls[0] == 1 or controls[1] == 1 or controls[2] == 1):
				get_parent().trainNN(inputs, controls)
			
	elif not deactivated and not Globals.paused:
		var distance1 = global_position.distance_to($RayCast1.get_collision_point())/320
		var distance2 = global_position.distance_to($RayCast2.get_collision_point())/320
		var distance3 = global_position.distance_to($RayCast3.get_collision_point())/320
		var distance4 = global_position.distance_to($RayCast4.get_collision_point())/320
		var distance5 = global_position.distance_to($RayCast5.get_collision_point())/320
		
		var inputs = [distance1, distance2, distance3, distance4, distance5]
		
		if trainingMode:
		
			var distance6 = global_position.distance_to($RayCast6.get_collision_point())/320
			var distance7 = global_position.distance_to($RayCast7.get_collision_point())/320
			var distance8 = global_position.distance_to($RayCast8.get_collision_point())/320
			var distance9 = global_position.distance_to($RayCast9.get_collision_point())/320
			
			inputs = [distance1, distance2, distance3, distance4, distance5, distance6, distance7, distance8, distance9]
		
		if DisplayNN:
			get_parent().get_parent().get_node("NnDisplay").forwardPass(network, inputs)
		
		
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
			velocity += Vector2(0, -speed * (isPos(wallThrust1) + isPos(wallThrust2)) * wallThrust).rotated(rotation)
	
	velocity *= friction
		
	move_and_slide()
	
	if deactivated and not waiting:
		waiting = true
		$flame.visible = false
		$PointLight2D.queue_free()
		awaitDeath()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is StaticBody2D:
			var collision_normal = collision.get_normal().rotated(-rotation)
			
			if collision_normal.y > 0 and not invincible:
				deactivated = true
				velocity = Vector2(0, 0)
			

func awaitDeath():
	await get_tree().create_timer(afterdeath).timeout
	queue_free()

func changeColor(col):
	$Wing.modulate = col
	$WingCore.modulate = col
	$PointLight2D.color = col

func isPos(val):
	if val > 0:
		return val
	return 0

func _on_wing_button_pressed():
	if not playable:
		get_parent().get_parent().setNNDisp(ID)
		Globals.saveWing(network)
		Globals.addWing(network)
