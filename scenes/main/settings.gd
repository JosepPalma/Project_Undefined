extends Node


signal player_settings_changed

const SETTINGS_FILE_PATH = "user://settings.cfg"
const PROJECT_SECTION = "Project"
const PLAYER_SECTION = "Player"
const VIEWPORT_SCALE_FACTOR = "display/window/stretch/scale"
const MAX_FPS_KEY = "application/run/max_fps"
const SENSITIVITY_KEY = "sensitivity"
const FOV_KEY = "fov"

var settings = ConfigFile.new()


func _ready():
	if not FileAccess.file_exists(SETTINGS_FILE_PATH):
		create_settings_file()
		return
	else:
		var err = settings.load(SETTINGS_FILE_PATH)
		if err != OK:
			return
		apply_all_settings()


func create_settings_file():
	settings.set_value(PROJECT_SECTION, VIEWPORT_SCALE_FACTOR, ProjectSettings.get_setting(VIEWPORT_SCALE_FACTOR))
	settings.set_value(PROJECT_SECTION, MAX_FPS_KEY, ProjectSettings.get_setting(MAX_FPS_KEY))
	
	settings.set_value(PLAYER_SECTION, SENSITIVITY_KEY, 50)
	settings.set_value(PLAYER_SECTION, FOV_KEY, 90)
	
	settings.save(SETTINGS_FILE_PATH)


func apply_setting(key: String, value):
	if key == VIEWPORT_SCALE_FACTOR:
		get_tree().root.content_scale_factor = value
	elif key == MAX_FPS_KEY:
		Engine.max_fps = value


# Apply settings from settings file to the project
func apply_all_settings():
	var viewport_scale_factor = settings.get_value(PROJECT_SECTION, VIEWPORT_SCALE_FACTOR)
	var max_fps = settings.get_value(PROJECT_SECTION, MAX_FPS_KEY)
	
	var sensitivity = settings.get_value(PLAYER_SECTION, SENSITIVITY_KEY)
	var fov = settings.get_value(PLAYER_SECTION, FOV_KEY)
	
	get_tree().root.content_scale_factor = viewport_scale_factor
	ProjectSettings.set_setting(MAX_FPS_KEY, max_fps)
	
	player_settings_changed.emit(sensitivity, fov)


func get_setting(section: String, key: String):
	return settings.get_value(section, key)


# Stores and applies the setting passed as an argument
func store_setting(section: String, key: String, value):
	settings.set_value(section, key, value)
	if section == PROJECT_SECTION:
		apply_setting(key, value)
	elif section == PLAYER_SECTION:
		player_settings_changed.emit(key, value)


# Saves settings file
func save_settings():
	settings.save(SETTINGS_FILE_PATH)
