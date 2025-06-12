extends Control

@onready var restartbutton = %Restart
@onready var menubutton = %Menu
@onready var quitbutton = %Quit
@onready var buttonSound = $AudioStreamPlayer2D

func _ready():
	Input.set_mouse_mode(Globalscript.mousemode)
	if OS.get_name() == "Web":
		quitbutton.visible = false

func _on_restart_pressed() -> void:
	buttonSound.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_menu_pressed() -> void:
	buttonSound.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://scenes/main menu/main_menu.tscn")


func _on_quit_pressed() -> void:
	buttonSound.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()
