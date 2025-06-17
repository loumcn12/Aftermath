extends Control
@onready var menudoor = get_node("../MainMenuDoor")  # adjust as needed
@onready var menu = get_node("../")
@onready var quitbutton = $VBoxContainer/quitbutton
@onready var buttonSound = $AudioStreamPlayer2D
@onready var versionLabel = $VersionLabel

func _ready():
	Input.set_mouse_mode(Globalscript.mousemode)
	if OS.get_name() == "Web":
		quitbutton.visible = false
	versionLabel.text = "Version " + str(ProjectSettings.get_setting("application/config/version"))
	
func _on_animation_done():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
func _on_startbutton_pressed() -> void:
	buttonSound.play()
	$VBoxContainer.visible = false
	# Ensure one-shot connection before playing
	menudoor.animation_done.connect(_on_animation_done, CONNECT_ONE_SHOT)
	menudoor.get_node("AnimationPlayer").play("menu_door_open")
	menu.get_node("WorldEnvironment").environment.volumetric_fog_enabled = true
	menu.get_node("FogVolume").visible = true

func _on_optionsbutton_pressed() -> void:
	buttonSound.play()
	$VBoxContainer.visible = false
	menu.get_node("OptionsMenu").visible = true


func _on_quitbutton_pressed() -> void:
	buttonSound.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()
