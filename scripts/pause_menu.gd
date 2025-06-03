extends Control
@onready var quitbutton = $PauseContainer/VBoxContainer/QuitGameButton
@onready var main = $"../"
@onready var PauseContainer = $PauseContainer
@onready var marginContainer = $MarginContainer
@onready var buttonSound = $AudioStreamPlayer2D

func _ready():
	if OS.get_name() == "Web":
		quitbutton.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape") and main.paused:
		main.pauseMenu()

func _cycleMenu():
	if PauseContainer.visible:
		PauseContainer.visible = false
	else:
		PauseContainer.visible = true
	
	if marginContainer.visible:
		marginContainer.visible = false
	else:
		marginContainer.visible = true

func _on_resume_button_pressed() -> void:
	buttonSound.play()
	await get_tree().create_timer(0.34).timeout
	main.pauseMenu()

func _on_restart_button_pressed() -> void:
	buttonSound.play()
	await get_tree().create_timer(0.2).timeout
	Globalscript.globalStamina = 100
	main.pauseMenu()
	get_tree().reload_current_scene()	
	
func _on_menu_button_pressed() -> void:
	buttonSound.play()
	_cycleMenu()

func _on_quit_game_button_pressed() -> void:
	buttonSound.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()
	
func _on_returnto_menu_pressed() -> void:
	buttonSound.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://scenes/main menu/main_menu.tscn")
