extends Node3D

signal animation_done

func _ready():
	$AnimationPlayer.animation_finished.connect(_on_anim_finished)

func _on_anim_finished(anim_name):
	if anim_name == "menu_door_open":
		emit_signal("animation_done")
