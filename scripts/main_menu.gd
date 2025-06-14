extends Control
@onready var quitbutton = $VBoxContainer/quitbutton
@onready var buttonSound = $AudioStreamPlayer2D
@onready var versionLabel = $VersionLabel

func _ready():
	Input.set_mouse_mode(Globalscript.mousemode)
	if OS.get_name() == "Web":
		quitbutton.visible = false
	versionLabel.text = "Version " + str(ProjectSettings.get_setting("application/config/version"))
		
func _on_startbutton_pressed() -> void:
	buttonSound.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_optionsbutton_pressed() -> void:
	buttonSound.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://scenes/main menu/options_menu.tscn")


func _on_quitbutton_pressed() -> void:
	buttonSound.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()
