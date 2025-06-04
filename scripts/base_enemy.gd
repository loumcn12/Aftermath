extends CharacterBody3D

@export var all_patrol_points: Array[Vector3] = [
	Vector3(0, 0, 0),
	Vector3(10, 0, 0),
	Vector3(20, 0, -15),
	Vector3(0, 0, -20),
	Vector3(20, 0, 6),
	Vector3(20, 0, -20),
	Vector3(-7, 0, -7),
	Vector3(-7, 0, -20)
]
@export var patrol_point_count: int = 3
@export var patrol_speed: float = 3.0
@export var chase_speed: float = 5.0
@export var wait_time_at_point: float = 1.0
@export var damage_amount: int = 10
@export var damage_delay: float = 1.0
@export var health: float = 100


var patrol_points: Array[Vector3] = []
var current_point_index := 0
var waiting := false
var wait_timer := 0.0
var chasing := false
var player: Node3D = null
var player_visible := false
var last_known_patrol_position: Vector3
var player_detected := false
var player_height = 1.5  # fallback
	


@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var detection_area: Area3D = $DetectionArea
@onready var damage_area: Area3D = $DamageArea
@onready var los_ray: RayCast3D = $LineOfSightRay
@onready var damage_timer: Timer = $DamageTimer
@onready var playerNode: Node3D = get_parent().get_node("player")
@onready var standing_shape_node: CollisionShape3D = playerNode.get_node("standing_collision_shape")
@onready var crouching_shape_node: CollisionShape3D = playerNode.get_node("crouching_collision_shape")
@onready var FootstepPlayer: AudioStreamPlayer3D = $FootstepPlayer



func _ready():
	
	los_ray.enabled = true

	# Shuffle the full list and select a subset
	if all_patrol_points.is_empty():
		push_warning("All patrol points are empty.")
		return

	var points_copy = all_patrol_points.duplicate()
	points_copy.shuffle()

	if patrol_point_count >= points_copy.size():
		patrol_points = points_copy
	else:
		patrol_points = points_copy.slice(0, patrol_point_count)

	current_point_index = 0
	agent.target_position = patrol_points[current_point_index]
	last_known_patrol_position = patrol_points[current_point_index]

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	
	damage_area.body_entered.connect(_on_damage_area_body_entered)
	damage_area.body_exited.connect(_on_damage_area_body_exited)
	
	damage_timer.timeout.connect(_on_damage_timer_timeout)
	damage_timer.wait_time = damage_delay

func _process(delta):
	"if velocity:
		if FootstepPlayer.playing == false:
			FootstepPlayer.play()
		
	else:
		FootstepPlayer.playing = false"
		
	if player_detected:
		_update_line_of_sight()
	# print("Chasing:", chasing, " Player valid:", is_instance_valid(player))
	if chasing and is_instance_valid(player):
		_update_line_of_sight()
		# print("LOS Update 2")
		if player_visible:
			agent.target_position = player.global_transform.origin
			move_towards_target(delta, chase_speed)
			return
		else:
			# Lost line of sight, stop chasing
			chasing = false
			player = null
			agent.target_position = last_known_patrol_position

	if waiting:
		wait_timer -= delta
		if wait_timer <= 0:
			waiting = false
			advance_to_next_point()
		return

	if agent.is_navigation_finished():
		waiting = true
		wait_timer = wait_time_at_point
		velocity = Vector3.ZERO
		return
	
	move_towards_target(delta, patrol_speed)

func move_towards_target(_delta: float, speed: float):
	var next_pos = agent.get_next_path_position()
	var dir = (next_pos - global_transform.origin).normalized()
	velocity = dir * speed
	move_and_slide()
	look_at(next_pos, Vector3.UP)

func advance_to_next_point():
	current_point_index = (current_point_index + 1) % patrol_points.size()
	last_known_patrol_position = patrol_points[current_point_index]
	agent.target_position = last_known_patrol_position

func _on_body_entered(body: Node):
	if body.is_in_group("player"):
		player = body
		player_detected = true
		player_height = get_active_player_shape_height()  # ← Update height here!
		_update_line_of_sight()
		if player_visible:
			chasing = true

func _on_body_exited(body: Node):
	if body == player:
		player_detected = false
		player = null
		chasing = false
		agent.target_position = last_known_patrol_position

func _on_damage_area_body_entered(body: Node):
	if body.is_in_group("player"):
		player = body
		damage_timer.start()
		
func _on_damage_area_body_exited(body: Node):
	if body.is_in_group("player"):
		damage_timer.stop()
		
func _on_damage_timer_timeout():
	if is_instance_valid(player):
		if player.is_in_group("player") and damage_area.get_overlapping_bodies().has(player):
			player._Damage(damage_amount)
			# print("Damaged player for", damage_amount)
			
func get_active_player_shape_height() -> float:
	if not is_instance_valid(playerNode):
		return player_height  # fallback default height

	if standing_shape_node and standing_shape_node is CollisionShape3D and standing_shape_node.visible:
		var shape = standing_shape_node.shape
		if shape is CapsuleShape3D:
			return shape.height
	elif crouching_shape_node and crouching_shape_node is CollisionShape3D and crouching_shape_node.visible:
		var shape = crouching_shape_node.shape
		if shape is CapsuleShape3D:
			return shape.height

	return player_height  # default if nothing is valid

func _damage(damage):
	if health > 0:
		health = health - damage
		print(health)
	if health <= 0:
		queue_free()

func _update_line_of_sight():
	if not is_instance_valid(player):
		player_visible = false
		return
		
	player_height = get_active_player_shape_height()
	
	var from_pos = global_transform.origin + Vector3.UP * 1.5
	var to_pos = player.global_transform.origin + Vector3.UP * (player_height / 2.0)

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from_pos, to_pos)
	query.exclude = [self]
	query.collide_with_areas = false
	query.collision_mask = 1 << 1  # Assuming player is on layer 2

	var result = space_state.intersect_ray(query)

	if result:
		var collider = result.collider
		# print("Ray hit:", collider.name)
		if collider.is_in_group("player"):
			player_visible = true
			chasing = true
			# print("🔴 Raycast HIT PLAYER")
		else:
			player_visible = false
			# print("🟠 Raycast hit something else")
	else:
		player_visible = false
		# print("⚪ Raycast missed everything")

	# Godot 4.5+ only: use this in the future
	# if Engine.is_editor_hint:
	#     var color = player_visible ? Color.GREEN : Color.YELLOW
	#     get_viewport().get_debug_draw().draw_line_3d(from_pos, to_pos, color)
