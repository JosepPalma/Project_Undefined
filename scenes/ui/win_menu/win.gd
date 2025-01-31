extends Control


const SCORE_TEXT = "Scanned gems: "
@onready var score_label = $WinBox/VBoxContainer/ScoreLabel
var score: int = -1


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	if get_parent().has_method("get_score"):
		score = get_parent().get_score()
	if score != -1:
		score_label.text = SCORE_TEXT + str(score)


func _on_retry_btn_pressed():
	var parent_node = get_parent()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	if parent_node.has_method("retry_game"):
		get_parent().retry_game()


func _on_exit_btn_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main/main_menu.tscn")
