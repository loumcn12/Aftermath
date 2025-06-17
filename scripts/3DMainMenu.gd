extends Node3D

func _ready() -> void:
	if OS.get_name() == "Web":
		$env/WorldEnvironment.environment.background_energy_multiplier = 5
		$env/WorldEnvironment.environment.sky.sky_material.energy_multiplier = 5
		$OmniLight3D.visible = true
