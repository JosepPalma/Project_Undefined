extends CharacterBody3D
## Character's code.
##
## This scripts includes both character movement and camera movement.
##

signal player_hitted
signal death

@export var speed = 4.5 ## Character movement speed
@export var jump_velocity = 5 ## Character jump velocity
@export var camera_sensitivity = 0.5 ## Camera sensitivity value
# Conversion factor from pixels in viewport to rads

var scale_factor = PI / 1_500 # PI rads = 1500 pixels
var health_points = 3 ## Character health

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Settings.player_settings_changed.connect(_on_player_settings_changed)
	$NeckPivot/Camera3D/RayCast3D.escape.connect(_on_player_escaped)


func _physics_process(delta):
	# Handle the movement from gravity/jumps
	update_vertical_velocity(delta)
	# Get the input direction and handle the movement/deceleration.
	update_movement_velocity()
	
	move_and_slide()


func _input(event):
	# Handle Mouse motion for the camera movement
	if event is InputEventMouseMotion:
		# Apply scale_factor and camera sensitivity value to relative movement on both x and y
		# coordinates
		rotate_y(-event.relative.x * scale_factor * camera_sensitivity)
		rotate_neck(-event.relative.y * scale_factor * camera_sensitivity)


#region Movement functions


func get_direction() -> Vector3:
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	return (global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()


func update_movement_velocity() -> void:
	var direction = get_direction()
	if direction: # Movement
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else: # Deceleration
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)


func update_vertical_velocity(delta) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity


#endregion


#region Camera functions


# Rotates NeckPivot from x axis to simulate neck movement when looking upwards or downwards
# Limited rotation from +90 degrees to -90 degrees
func rotate_neck(rotation_angle):
	var final_neck_angle = $NeckPivot.rotation.x + rotation_angle
	if final_neck_angle <= PI/2 and final_neck_angle >= -PI/2:
		$NeckPivot.rotate_x(rotation_angle)
	elif final_neck_angle >= PI/2:
		$NeckPivot.rotate_x(PI/2 - $NeckPivot.rotation.x)
	elif final_neck_angle <= -PI/2:
		$NeckPivot.rotate_x(-PI/2 - $NeckPivot.rotation.x)


#endregion


#region hit functions


# Player has been hitted
func take_damage():
	decrease_health()
	print(health_points)
	check_is_alive()


func decrease_health():
	if health_points > 0:
		health_points -= 1
		player_hitted.emit(health_points)


# Checks health points and emits death signal if dead
func check_is_alive():
	if health_points == 0:
		death.emit()


#endregion

# Change on settings call
func _on_player_settings_changed(setting: String, value):
	if (setting == Settings.SENSITIVITY_KEY):
		camera_sensitivity = value/100
	elif (setting == Settings.FOV_KEY):
		$NeckPivot/Camera3D.fov = value


func _on_player_escaped():
	get_tree().get_root().get_node("Main").end_game()
