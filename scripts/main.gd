extends Node3D

@onready var pause_menu = $PauseMenu
@onready var hud = $player/PlayerHud
@onready var player = $player
var paused = false

# const BUILDINGS_PATH = "res://scenes/buildings/"
# var TILE_SIZE = 20.0 (Not currently used)

# Coordinates for each building size
var tile_origins := {
	"1x1": [
		{ "position": Vector3(0, 0, 0), "rotation": Vector3(0, 0, 0) },
	],
	"2x1": [
		
	],
	"2x2": [
		
	],
	"3x1": [
		
	],
	"3x2": [
		
	],
	"3x3": [
		
	]
}

var building_scenes := {}  # Dictionary: "2x1" -> [PackedScene]

func _ready() -> void:
	if OS.get_name() == "Web":
		$env/WorldEnvironment.environment.background_energy_multiplier = 1.3
	pause_menu.hide()
	get_tree().paused = false
	hud.visible = true
	paused = false
	load_building_models()
	place_buildings()
	
func load_building_models():
	var building_files = [
		"res://scenes/buildings/1x1_apartments.tscn",
		"res://scenes/buildings/1x1_bunker.tscn",
		"res://scenes/buildings/1x1_hanger.tscn",
		"res://scenes/buildings/1x1_hospital.tscn",
		"res://scenes/buildings/1x1_skyscraper.tscn",
		"res://scenes/buildings/1x1_statue.tscn",
		"res://scenes/buildings/1x1_tower.tscn",
		"res://scenes/buildings/1x1_waccas.tscn",
		"res://scenes/buildings/1x1_water.tscn",
		"res://scenes/buildings/2x1_buildings.tscn",
		"res://scenes/buildings/2x1_buildings.tscn",
		"res://scenes/buildings/2x1_hospital.tscn",
		"res://scenes/buildings/2x1_PizzaHut.tscn",
		"res://scenes/buildings/2x1_School.tscn",
		"res://scenes/buildings/2x2_Hospital.tscn",
		"res://scenes/buildings/2x2_ParkingGarage.tscn",
		"res://scenes/buildings/2x2_ParkingLot.tscn",
		"res://scenes/buildings/2x2_Supermarket.tscn",
		"res://scenes/buildings/3x1_Apartments.tscn",
		"res://scenes/buildings/3x1_Buildings.tscn",
		"res://scenes/buildings/3x1_Buildings_2.tscn",
		"res://scenes/buildings/3x1_Buildings_3.tscn",
		"res://scenes/buildings/3x2_Museum.tscn",
		"res://scenes/buildings/3x2_Runway.tscn",
		"res://scenes/buildings/3x3_Nuclear.tscn",
	]

	for path in building_files:
		var size_key = path.get_file().split("_")[0]
		var scene = load(path)
		if scene:
			if not building_scenes.has(size_key):
				building_scenes[size_key] = []
			building_scenes[size_key].append(scene)

func place_buildings():
	for size_key in tile_origins.keys():
		if not building_scenes.has(size_key):
			continue
		for tile_data in tile_origins[size_key]:
			var building_position = tile_data["position"]
			var building_rotation_degrees = tile_data["rotation"]
			var building_scene = building_scenes[size_key].pick_random()
			if building_scene:
				place_building(building_scene, building_position, building_rotation_degrees)
				
func place_building(scene: PackedScene, origin: Vector3, building_rotation_degrees: Vector3):
	var instance = scene.instantiate()
	instance.transform.origin = origin
	instance.rotation_degrees = building_rotation_degrees
	add_child(instance)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		pauseMenu()

	if player.position.y < -5:
		player._Damage(player.position.y * -0.008)

func pauseMenu():
	if paused:
		pause_menu.hide()
		get_tree().paused = false
		hud.visible = true
	else:
		pause_menu.show()
		get_tree().paused = true
		Input.set_mouse_mode(Globalscript.mousemode)
		hud.visible = false
	await get_tree().create_timer(0.1).timeout
	paused = !paused
