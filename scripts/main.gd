extends Node3D

@onready var pause_menu = $PauseMenu
@onready var hud = $player/PlayerHud
@onready var player = $player
var paused = false

const BUILDINGS_PATH = "res://assets/buildings/"
var TILE_SIZE = 20.0  # Set to 30.0 if that's your unit size

# You manually provide coordinates per size
var tile_origins := {
	"3x3": [Vector3(0, 0, -80), Vector3(0, 0, -120)],
	"3x2": [Vector3(-64, 0, 0), Vector3(-64, 0, -40),Vector3(-64, 0 ,-80), Vector3(-64, 0 ,-120)],
	"3x1": [Vector3(-128, 0, 0), Vector3(-128, 0, -40), Vector3(-128, 0 ,-80), Vector3(-128, 0 ,-120)],
	"2x2": [Vector3(64, 0, 0), Vector3(64, 0, -40), Vector3(64, 0 ,-80), Vector3(64, 0 ,-120)],
	"2x1": [Vector3(128, 0, 0), Vector3(128, 0, -40), Vector3(128, 0 , -80), Vector3(128, 0 , -120)],
	"1x1": [Vector3(192, 0, 0), Vector3(192, 0, -40), Vector3(192, 0, -80), Vector3(192, 0 , -120), Vector3(-192, 0 ,0), Vector3(-192, 0 , -40), Vector3(-192, 0 , -80), Vector3(-192, 0 , -120)]
}

var building_scenes := {}  # Dictionary: "2x1" -> [PackedScene]

func _ready() -> void:
	pause_menu.hide()
	get_tree().paused = false
	hud.visible = true
	paused = false
	load_building_models()
	place_buildings()

func load_building_models():
	var dir = DirAccess.open(BUILDINGS_PATH)
	if dir == null:
		push_error("Failed to open building directory.")
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".glb"):
			var size_key = file_name.split("_")[0]  # e.g. "2x1" from "2x1_factory.glb"
			if not building_scenes.has(size_key):
				building_scenes[size_key] = []
			var scene = load(BUILDINGS_PATH + file_name)
			if scene:
				building_scenes[size_key].append(scene)
		file_name = dir.get_next()
	dir.list_dir_end()

func place_buildings():
	for size_key in tile_origins.keys():
		if not building_scenes.has(size_key):
			continue  # No buildings of this size
		for origin in tile_origins[size_key]:
			var building_scene = building_scenes[size_key].pick_random()
			if building_scene:
				place_building(building_scene, origin)

func place_building(scene: PackedScene, origin: Vector3):
	var instance = scene.instantiate()
	instance.transform.origin = origin
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
	
