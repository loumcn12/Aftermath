extends Control
@onready var fullscreen = $VBoxContainer/fullscreensetting/fullscreenbutton
@onready var windowmode = $VBoxContainer/windowmodesetting/OptionButton
@onready var crosshair = $VBoxContainer/crosshairsetting/crosshairbutton
var pausemenu
@onready var fpsbutton = $VBoxContainer/FPSsetting/fpsbutton
@onready var buttonSound = $AudioStreamPlayer2D
@onready var versionLabel = $VersionLabel

# Calls when the scene is loaded
func _ready() -> void:
	# Disables the fullscreen button for web browsers (Handled separately)
	versionLabel.text = "Version " + str(ProjectSettings.get_setting("application/config/version"))
	if OS.get_name() == "Web":
		fullscreen.disabled = true
	if "OptionsMenu" in str(get_tree().current_scene):
		pass
	else:
		pausemenu = $"../.."
		
# Calls every frame
func _process(_delta: float) -> void:
	
	# Changes the window mode between fullscreen and windowed
	if fullscreen.button_pressed:
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
		
	if fpsbutton.button_pressed:
		Globalscript.showFPS = true
	else:
		Globalscript.showFPS = false

# Returns the user to the main menu
func _on_back_button_pressed() -> void:
	buttonSound.play()
	await get_tree().create_timer(0.2).timeout
	
	if "MainMenu" in str(get_tree().current_scene):
		get_node("../MainMenu/VBoxContainer").visible = true
		$"../OptionsMenu".visible = false
	else:
		pausemenu._cycleMenu()
