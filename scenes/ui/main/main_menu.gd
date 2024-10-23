extends Control


@onready var options_menu = preload("res://scenes/ui/options/options_menu.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)


func _on_play_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")


func _on_options_btn_pressed():
	add_child(options_menu.instantiate())


func _on_exit_btn_pressed():
	get_tree().quit()
