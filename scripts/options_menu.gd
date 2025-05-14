extends Control
@onready var fullscreen = $VBoxContainer/fullscreensetting/fullscreenbutton

# Calls when the scene is loaded
func _ready() -> void:
	# Disables the fullscreen button for web browsers (Handled separately)
	if (OS.get_name() != "Windows") and (OS.get_name() != "Linux"):
		fullscreen.disabled = true
		
# Calls every frame
func _physics_process(_delta: float) -> void:
	
	# Changes the window mode between fullscreen and windowed
	if fullscreen.button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# Returns the user to the main menu
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main menu/main_menu.tscn")
