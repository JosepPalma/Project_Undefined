extends Node


@onready var pause_menu = preload("res://scenes/ui/pause/pause_menu.tscn")
@onready var respawn_menu = preload("res://scenes/ui/respawn/respawn.tscn")
@onready var win_menu = preload("res://scenes/ui/win_menu/win.tscn")
var score: int = 0


func _init():
	# Set the mouse mode to Captured to lock the cursor and hide it.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called when the node enters the scene tree for the first time.
func _ready():
	print("pre-connect")
	$ProceduralMap/NavigationRegion3D.map_created.connect(_on_map_created)
	print("post-connect")
	$ProceduralMap/NavigationRegion3D.get_map_createion_check()
	print("post-check")
	$GemManager.score_incremented.connect(_on_gem_scanned)
	
	score = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	# Pause game, enable cursor and show pause menu
	if event.is_action("open_menu") and not get_tree().paused:
		add_child(pause_menu.instantiate())


func get_score() -> int:
	return score


func get_random_gem_position():
	return $GemManager.get_random_gem_position()


func _on_map_created():
	print("Connecting entities")
	var players = get_tree().get_nodes_in_group("Player")
	for player in players:
		player.player_hitted.connect(_on_player_hitted)
		player.death.connect(_on_player_death)


func _on_gem_scanned():
	print("score incremented")
	score = score + 1
	$HUD.set_score(score)


func _on_player_hitted(health_points):
	$HUD.decrease_health_bar(health_points)


func _on_player_death():
	add_child(respawn_menu.instantiate())


func retry_game():
	get_tree().reload_current_scene()

func end_game():
	add_child(win_menu.instantiate())
