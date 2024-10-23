extends Control

@onready var controls_panel = $ControlsPanel as Panel
@onready var resolution_options = $Menu/VBoxContainer/GridContainer/ResolutionOptBtn as OptionButton
@onready var fps_options = $Menu/VBoxContainer/GridContainer/FramerateOptBtn as OptionButton
@onready var sensitivity_slider = $Menu/VBoxContainer/GridContainer/SensitivityControl/SensitivitySlider as Slider
@onready var sensitivity_value_label = $Menu/VBoxContainer/GridContainer/SensitivityControl/SensitivitySliderLabel as Label
@onready var fov_slider = $Menu/VBoxContainer/GridContainer/FOVControl/FOVSlider as Slider
@onready var fov_value_label = $Menu/VBoxContainer/GridContainer/FOVControl/FOVSliderLabel as Label
@onready var apply_btn = $Menu/ApplyBtn as Button


var opt_viewport_scale_factor
var opt_fps_value
var opt_sensitivity_value
var opt_fov_value


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	recover_settings()
	sensitivity_value_label.text = str(sensitivity_slider.value)
	fov_value_label.text = str(fov_slider.value)


# Recovers settings from settings file
func recover_settings():
	var settings_viewport_scale_factor = Settings.get_setting(Settings.PROJECT_SECTION, Settings.VIEWPORT_SCALE_FACTOR)
	var settings_fps_value = Settings.get_setting(Settings.PROJECT_SECTION, Settings.MAX_FPS_KEY)
	var settings_sensitivity_value = Settings.get_setting(Settings.PLAYER_SECTION, Settings.SENSITIVITY_KEY)
	var settings_fov_value = Settings.get_setting(Settings.PLAYER_SECTION, Settings.FOV_KEY)
	
	set_resolution_options(settings_viewport_scale_factor)
	set_fps_options(settings_fps_value)
	sensitivity_slider.value = settings_sensitivity_value
	sensitivity_value_label.text = str(settings_sensitivity_value)
	fov_slider.value = settings_fov_value
	fov_value_label.text = str(settings_fov_value)


# Sends all modified settings to settings singleton
func store_settings():
	if opt_viewport_scale_factor != null:
		Settings.store_setting(Settings.PROJECT_SECTION, Settings.VIEWPORT_SCALE_FACTOR, opt_viewport_scale_factor)
	if opt_fps_value != null:
		Settings.store_setting(Settings.PROJECT_SECTION, Settings.MAX_FPS_KEY, opt_fps_value)
	if opt_sensitivity_value != null:
		Settings.store_setting(Settings.PLAYER_SECTION, Settings.SENSITIVITY_KEY, opt_sensitivity_value)
	if opt_fov_value != null:
		Settings.store_setting(Settings.PLAYER_SECTION, Settings.FOV_KEY, opt_fov_value)


# Selects resolution item using saved scale factor
func set_resolution_options(value):
	match value:
		1.5:
			resolution_options.selected = 0
		1.0:
			resolution_options.selected = 1
		0.75:
			resolution_options.selected = 2


func set_fps_options(value):
	match value:
		30:
			fps_options.selected = 0
		60:
			fps_options.selected = 1
		120:
			fps_options.selected = 2
		144:
			fps_options.selected = 3


# Set to null all opt variables to later store only modified ones
func empty_opt_variables():
	opt_viewport_scale_factor = null
	opt_fps_value = null
	opt_sensitivity_value = null
	opt_fov_value = null


func _on_apply_btn_pressed():
	store_settings()
	Settings.save_settings()
	empty_opt_variables()
	apply_btn.disabled = true


# Sets viewport scale factor based on resolution selection
func _on_resolution_item_selected(index: int):
	apply_btn.disabled = false
	var factor
	match index:
		0:
			opt_viewport_scale_factor = 1.5
		1:
			opt_viewport_scale_factor = 1.0
		2:
			opt_viewport_scale_factor = 0.75


func _on_fps_item_selected(index: int):
	apply_btn.disabled = false
	match index:
		0:
			opt_fps_value = 30
		1:
			opt_fps_value = 60
		2:
			opt_fps_value = 120
		3:
			opt_fps_value = 144


func _on_sensitivity_slider_drag_ended(value_changed: bool):
	if (value_changed):
		apply_btn.disabled = false
		opt_sensitivity_value = sensitivity_slider.value


func _on_fov_slider_drag_ended(value_changed: bool):
	if (value_changed):
		apply_btn.disabled = false
		opt_fov_value = fov_slider.value


func _on_sensitivity_slider_value_changed(value: float):
	sensitivity_value_label.text = str(value)


func _on_fov_slider_value_changed(value: float):
	fov_value_label.text = str(value)


func _on_controls_btn_pressed():
	controls_panel.show()


func _on_return_btn_pressed():
	queue_free()
