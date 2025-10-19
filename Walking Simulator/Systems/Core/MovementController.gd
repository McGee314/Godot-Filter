extends Node

# Movement parameters
@export var max_speed: float = 4.0
@export var acceleration: float = 20.0
@export var braking: float = 20.0
@export var air_acceleration: float = 4.0
@export var jump_force: float = 5.0
@export var gravity_modifier: float = 1.5
@export var max_run_speed: float = 6.0

# Movement state
var velocity: Vector3 = Vector3.ZERO
var is_running: bool = false
var is_on_ground: bool = true

# Physics
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_modifier

# Reference to the character body
var character_body: CharacterBody3D
var input_manager: Node

func _ready():
	# Get reference to the character body
	character_body = get_parent() as CharacterBody3D
	if not character_body:
		push_error("MovementController must be a child of CharacterBody3D")
	
	# Get reference to input manager
	input_manager = character_body.get_node("InputManager")
	if not input_manager:
		push_error("InputManager not found - please add it as a child of the character body")

func _physics_process(delta: float):
	_update_ground_state()
	_apply_gravity(delta)
	_handle_jumping(delta)
	_handle_horizontal_movement(delta)
	_apply_movement(delta)

func _update_ground_state():
	# Check if character is on ground
	is_on_ground = character_body.is_on_floor() or character_body.position.y <= 1.1

func _apply_gravity(delta: float):
	if not is_on_ground:
		velocity.y -= gravity * delta

func _handle_jumping(_delta: float):
	# Jump logic
	if input_manager and input_manager.is_jump_pressed() and is_on_ground:
		velocity.y = jump_force

func _handle_horizontal_movement(delta: float):
	if not input_manager:
		return
		
	var move_input = input_manager.get_move_input()
	
	if move_input != Vector2.ZERO:
		# Determine movement speed
		var current_speed = max_speed
		if input_manager.is_sprint_pressed():
			current_speed = max_run_speed
			is_running = true
		else:
			is_running = false
		
		# Get camera reference for movement direction
		var camera = character_body.get_node("Camera3D") as Camera3D
		if not camera:
			return
		
		# Calculate movement based on camera direction
		var camera_forward = -camera.global_transform.basis.z
		var camera_right = camera.global_transform.basis.x
		
		# Remove Y component to keep movement horizontal
		camera_forward.y = 0
		camera_right.y = 0
		camera_forward = camera_forward.normalized()
		camera_right = camera_right.normalized()
		
		# Calculate movement direction
		var move_direction = Vector3.ZERO
		move_direction += camera_forward * -move_input.y  # Forward/backward
		move_direction += camera_right * move_input.x     # Left/right
		
		# Apply acceleration
		var target_velocity = move_direction * current_speed
		var acceleration_rate = acceleration if is_on_ground else air_acceleration
		
		velocity.x = lerp(velocity.x, target_velocity.x, acceleration_rate * delta)
		velocity.z = lerp(velocity.z, target_velocity.z, acceleration_rate * delta)
	else:
		# Apply braking when no input
		var braking_rate = braking if is_on_ground else air_acceleration
		velocity.x = lerp(velocity.x, 0.0, braking_rate * delta)
		velocity.z = lerp(velocity.z, 0.0, braking_rate * delta)
		is_running = false

func _apply_movement(delta: float):
	# Apply velocity to character body
	character_body.velocity = velocity
	character_body.move_and_slide()
	
	# Update velocity from character body (for collision handling)
	velocity = character_body.velocity
	
	# Simple ground collision - prevent going below Y=1.0
	if character_body.position.y < 1.0:
		character_body.position.y = 1.0
		velocity.y = 0

func get_velocity() -> Vector3:
	return velocity

func get_is_running() -> bool:
	return is_running

func get_is_on_ground() -> bool:
	return is_on_ground

func set_movement_parameters(params: Dictionary):
	if params.has("max_speed"):
		max_speed = params.max_speed
	if params.has("acceleration"):
		acceleration = params.acceleration
	if params.has("braking"):
		braking = params.braking
	if params.has("jump_force"):
		jump_force = params.jump_force
	if params.has("max_run_speed"):
		max_run_speed = params.max_run_speed
