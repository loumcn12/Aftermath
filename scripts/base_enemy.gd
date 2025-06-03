extends CharacterBody3D

# Possible points the enemy can patrol between
@export var patrol_points: Array[Vector3] = [
	Vector3(0, 0, 0),
	Vector3(10, 0, 0),
	Vector3(20, 0, -15),
	Vector3(0, 0, -20)
]

# The number of points the enemy will pick at random to patrol between
@export var patrol_count: int = 4

# Other behaviour variables
@export var patrol_speed: float = 3.0
@export var chase_speed: float = 5.0
@export var wait_time_at_point: float = 1.0
@export var damage_amount: int = 10
@export var damage_delay: float = 1.0

var selected_patrol_points: Array[Vector3] = []
var current_point_index := 0
var waiting := false
var wait_timer := 0.0
var chasing := false
var player: Node3D = null
var player_visible := false
var last_known_patrol_position: Vector3
var player_detected := false
var player_height = 1.0  # fallback

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var detection_area: Area3D = $DetectionArea
@onready var damage_area: Area3D = $DamageArea
@onready var los_ray: RayCast3D = $LineOfSightRay
@onready var damage_timer: Timer = $DamageTimer
@onready var playerNode: Node3D = get_parent().get_node("player")
@onready var standing_shape_node: CollisionShape3D = playerNode.get_node("standing_collision_shape")
@onready var crouching_shape_node: CollisionShape3D = playerNode.get_node("crouching_collision_shape")

func _ready():
	los_ray.enabled = true

	if patrol_points.is_empty():
		push_warning("Patrol points are empty.")
		return

	# Randomly pick patrol points
	selected_patrol_points = patrol_points.duplicate()
	selected_patrol_points.shuffle()
	if patrol_count < selected_patrol_points.size():
		selected_patrol_points.resize(patrol_count)

	agent.target_position = selected_patrol_points[current_point_index]

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	damage_area.body_entered.connect(_on_damage_area_body_entered)
	damage_area.body_exited.connect(_on_damage_area_body_exited)
	damage_timer.timeout.connect(_on_damage_timer_timeout)
	damage_timer.wait_time = damage_delay

func _process(delta):
	if player_detected:
		_update_line_of_sight()

	if chasing and is_instance_valid(player):
		_update_line_of_sight()
		if player_visible:
			agent.target_position = player.global_transform.origin
			move_towards_target(delta, chase_speed)
			return
		else:
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
	current_point_index = (current_point_index + 1) % selected_patrol_points.size()
	last_known_patrol_position = selected_patrol_points[current_point_index]
	agent.target_position = last_known_patrol_position
	

func _on_body_entered(body: Node):
	# print("Entered:", body.name, " Groups:", body.get_groups())
	if body.is_in_group("player"):
		player = body
		player_detected = true
		_update_line_of_sight()
		# print("LOS Update 3")
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
		return 1.5  # fallback default height

	if standing_shape_node and standing_shape_node is CollisionShape3D and standing_shape_node.visible:
		var shape = standing_shape_node.shape
		if shape is CapsuleShape3D:
			return shape.height
	elif crouching_shape_node and crouching_shape_node is CollisionShape3D and crouching_shape_node.visible:
		var shape = crouching_shape_node.shape
		if shape is CapsuleShape3D:
			return shape.height

	return 1.5  # default if nothing is valid

func _update_line_of_sight():
	if not is_instance_valid(player):
		player_visible = false
		return

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
			# print("Raycast HIT PLAYER")
		else:
			player_visible = false
			# print("Raycast hit something else")
	else:
		player_visible = false
		# print("Raycast missed everything")

	# Godot 4.5+ only: use this in the future
	# if Engine.is_editor_hint:
	#     var color = player_visible ? Color.GREEN : Color.YELLOW
	#     get_viewport().get_debug_draw().draw_line_3d(from_pos, to_pos, color)
