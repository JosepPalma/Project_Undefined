extends CharacterBody3D

enum states {IDLE, WANDER, CHASE, ATTACK} # Monster's states
# IDLE = Monster stays in place
# WANDER = Monster moves trough the map
# CHASE = Monster follows the player
# ATTACK = Monster attacks the player

const MAX_SPEED = 2.5
@export var total_destinations = 3
@export var speed = MAX_SPEED
@export var max_idle_time = 1.5
@export var attack_rate = 0.75
var elapsed_idle_time = 0.0
var elapsed_time_between_attacks = 0.0
var attack = false
var current_state
var player
var target
var orientation
@onready var spawn_point: Vector3 = global_position
@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")


func _ready():
	randomize()
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	
	current_state = states.IDLE
	target = spawn_point


func _process(delta):
	match current_state:
		states.IDLE:
			speed = 0
			check_idle_time(delta)
		states.WANDER:
			speed = MAX_SPEED
			#set_movement_target(target)
		states.CHASE:
			speed = MAX_SPEED
			if player != null:
				set_movement_target(player.global_position)
		states.ATTACK:
			attack_player(delta)


func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		if current_state == states.CHASE:
			current_state = states.IDLE
		elif current_state == states.WANDER:
			current_state = states.IDLE
		return
	
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * speed
	#if new_velocity.:
	#orientation = Basis.looking_at(global_position.direction_to(new_velocity))
	#basis = basis.slerp(orientation, 1.)
	#var vec1: Vector3 = Vector3(global_position.x, 0, global_position.z)
	#var vec2: Vector3 = Vector3(next_path_position.x, 0, next_path_position.z)
	
	var lookAtPosition = Vector3(next_path_position.x, global_position.y, next_path_position.z)
	if lookAtPosition != global_position:
		look_at(lookAtPosition, Vector3.UP)
	
	# Checks avoidance, future use if multiple NavigationAgent are set
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)


# Sets a target for the monster
func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)


# Checks if maximum idle time passed and changes states if so
func check_idle_time(delta):
	elapsed_idle_time += delta
	if elapsed_idle_time >= max_idle_time:
		target = get_wander_destination()
		set_movement_target(target)
		current_state = states.WANDER
		elapsed_idle_time = 0.0


# Randomly sets the navigation target to a gem position or spawn point
# Used total_destinations as total number of possible destinations
# Random factor of returning to spawnpoint = 1/total_destinatios
func get_wander_destination():
	if get_tree().get_root().get_node("Main").has_method("get_random_gem_position") and (randi() % total_destinations) != 0:
		return get_tree().get_root().get_node("Main").get_random_gem_position()
	else:
		return spawn_point


func attack_player(delta):
	# Checks attack rate time passed
	if elapsed_time_between_attacks >= attack_rate:
		player.take_damage() # Player gets hit
		elapsed_time_between_attacks = 0
	else:
		elapsed_time_between_attacks += delta


func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()


# Player entered nearby area
func _on_player_detected(body: Node3D):
	print("Player detected")
	elapsed_idle_time = 0.0
	current_state = states.CHASE
	player = body


# Player exited nearby area
func _on_player_lost(body: Node3D):
	print("Player lost")
	current_state = states.IDLE
	player = null


# Player is close enough to be attacked
func _on_player_in_attack_range(body: Node3D):
	print("Attack started")
	current_state = states.ATTACK


# Player exited the attack area
func _on_player_left_attack_range(body: Node3D):
	current_state = states.CHASE
