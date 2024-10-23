extends Control

signal quit_game

@onready var options_menu = preload("res://scenes/ui/options/options_menu.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _input(event):
	if event.is_action("open_menu"):
		pass


# Enable cursor and hide pause menu
func resume_game():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	queue_free()


func _on_resume_btn_pressed():
	resume_game()


func _on_options_btn_pressed():
	add_child(options_menu.instantiate())


func _on_exit_btn_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main/main_menu.tscn")
