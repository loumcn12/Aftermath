extends Control
@onready var menudoor = get_node("../MainMenuDoor")  # adjust as needed
@onready var menu = get_node("../")
@onready var quitbutton = $VBoxContainer/quitbutton
@onready var buttonSound = $AudioStreamPlayer2D
@onready var versionLabel = $VersionLabel
var level

func _ready():
	Input.set_mouse_mode(Globalscript.mousemode)
	if OS.get_name() == "Web":
		quitbutton.visible = false
	versionLabel.text = "Version " + str(ProjectSettings.get_setting("application/config/version"))
	
func _on_animation_done():
	if level == 1:
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	elif level == 2:
		get_tree().change_scene_to_file("res://scenes/level2.tscn")
	
func _on_startbutton_pressed() -> void:
	level = 1
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


func _on_startbutton_2_pressed() -> void:
	level = 2
	buttonSound.play()
	$VBoxContainer.visible = false
	# Ensure one-shot connection before playing
	menudoor.animation_done.connect(_on_animation_done, CONNECT_ONE_SHOT)
	menudoor.get_node("AnimationPlayer").play("menu_door_open")
	menu.get_node("WorldEnvironment").environment.volumetric_fog_enabled = true
	menu.get_node("FogVolume").visible = true
