extends Control
@onready var fullscreen = $VBoxContainer/fullscreensetting/fullscreenbutton
@onready var windowmode = $VBoxContainer/windowmodesetting/OptionButton
@onready var crosshair = $VBoxContainer/crosshairsetting/crosshairbutton
@onready var pausemenu = $"../.."

# Calls when the scene is loaded
func _ready() -> void:
	# Disables the fullscreen button for web browsers (Handled separately)
	if OS.get_name() == "Web":
		fullscreen.disabled = true
		
# Calls every frame
func _process(_delta: float) -> void:
	
	# Changes the window mode between fullscreen and windowed
	if fullscreen.button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
	if windowmode.selected == 0:
		Globalscript.mousemode = Input.MOUSE_MODE_VISIBLE
		Input.set_mouse_mode(Globalscript.mousemode)
	else:
		Globalscript.mousemode = Input.MOUSE_MODE_CONFINED
		Input.set_mouse_mode(Globalscript.mousemode)
		
	if crosshair.button_pressed:
		Globalscript.crosshair = true
	else:
		Globalscript.crosshair = false

# Returns the user to the main menu
func _on_back_button_pressed() -> void:
	if "OptionsMenu" in str(get_tree().current_scene):
		get_tree().change_scene_to_file("res://scenes/main menu/main_menu.tscn")
	else:
		pausemenu._cycleMenu()
