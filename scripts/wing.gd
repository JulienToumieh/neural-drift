extends CharacterBody2D

const speed = 22.0
var rotation_speed = 0.07
var friction = 0.9
var wallThrust = 2.5

var deactivated = false
var afterdeath = 20.0


@export var color = Color("#FFFFFF")
@export var playable = false
@export var network = {}
@export var ID = -1

var DisplayNN = false

var waiting = false

func _ready():
	changeColor(color)
	if not playable:
		changeColor(generate_light_vibrant_color())
		if network.is_empty():
			network = GANN.generateRandomNN(5, 6, 3)
			

func generate_light_vibrant_color() -> Color:
	var r = randf_range(0.4, 1.0)
	var g = randf_range(0.4, 1.0)  
	var b = randf_range(0.4, 1.0) 
	
	return Color(r, g, b)


func _physics_process(delta):
	if playable and not deactivated:
		if Input.is_action_pressed("ui_up"):
			velocity += Vector2(0, -speed).rotated(rotation)
		if Input.is_action_pressed("ui_left"):
			rotation -= rotation_speed
			#velocity += Vector2(0, -SPEED * 0.02).rotated(rotation)
		if Input.is_action_pressed("ui_right"):
			rotation += rotation_speed
			#velocity += Vector2(0, -SPEED * 0.02).rotated(rotation)
		
		if Input.is_action_pressed("ui_down"):
			velocity += Vector2(0, speed).rotated(rotation)
		
		if Input.is_action_just_released("ui_up"):
			$flame.visible = false
		if Input.is_action_just_pressed("ui_up"):
			$flame.visible = true
		
		if ($BackRay1.is_colliding() or $BackRay2.is_colliding()) and Input.is_action_pressed("ui_up"):
			var wallThrust1 = 1 - global_position.distance_to($BackRay1.get_collision_point())/50
			var wallThrust2 = 1 - global_position.distance_to($BackRay2.get_collision_point())/50
			velocity += Vector2(0, -speed * (isPos(wallThrust1) + isPos(wallThrust2)) * wallThrust).rotated(rotation)
			
	elif not deactivated and not Globals.paused:
		var distance1 = global_position.distance_to($RayCast1.get_collision_point())/320
		var distance2 = global_position.distance_to($RayCast2.get_collision_point())/320
		var distance3 = global_position.distance_to($RayCast3.get_collision_point())/320
		var distance4 = global_position.distance_to($RayCast4.get_collision_point())/320
		var distance5 = global_position.distance_to($RayCast5.get_collision_point())/320
		
		var inputs = [distance1, distance2, distance3, distance4, distance5]
		
		if DisplayNN:
			print(ID)
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
		if collision.get_collider() is StaticBody2D: # and not playable:
			var collision_normal = collision.get_normal().rotated(-rotation)
			
			
			if collision_normal.y > 0:
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
	Globals.addWing(network)
