extends Control
@onready var quitbutton = $MarginContainer/VBoxContainer/QuitGameButton
@onready var main = $"../"

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape") and main.paused:
		main.pauseMenu()

func _on_resume_button_pressed() -> void:
	main.pauseMenu()

func _on_restart_button_pressed() -> void:
	main.pauseMenu()
	get_tree().reload_current_scene()

func _on_quit_game_button_pressed() -> void:
	OS.crash("You Quit the Game!")
