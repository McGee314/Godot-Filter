extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var camera: Camera3D = $Player/Camera3D

# Movement settings (from PlayerControllerRefactored.gd)
var MOVE_SPEED: float = 8.0
var RUN_SPEED: float = 16.0
var JUMP_FORCE: float = 15.0
var ACCELERATION: float = 25.0
var DECELERATION: float = 30.0
var AIR_CONTROL: float = 0.3

# Physics settings (from PlayerControllerRefactored.gd)
var gravity: float = 40.0
var max_fall_speed: float = 50.0

# Complex physics variables
var current_speed: float = 0.0
var target_speed: float = 0.0
var velocity_horizontal: Vector2 = Vector2.ZERO
var is_running: bool = false
var is_grounded: bool = false

# Jump cooldown (from working simple version)
var jump_cooldown: float = 0.0
var jump_delay: float = 0.3

func _ready():
	print("Complex Physics Test initialized")
	print("Testing: Complex physics + Simple camera + Direct input")
	print("Controls: WASD = Move, SHIFT = Run, SPACE = Jump, ESC = Exit")

func _physics_process(delta: float):
	# Update grounded state
	is_grounded = player.is_on_floor()
	
	# Handle movement with complex physics
	handle_movement_complex(delta)
	
	# Apply physics
	apply_physics(delta)
	
	# Move player
	player.move_and_slide()
	
	# Debug output
	debug_physics()

func handle_movement_complex(delta: float):
	# Get input direction (simple camera-relative)
	var input_direction: Vector3 = get_camera_relative_input()
	
	# Determine if running
	is_running = Input.is_key_pressed(KEY_SHIFT)
	
	# Calculate target speed
	if input_direction.length() > 0.1:
		target_speed = RUN_SPEED if is_running else MOVE_SPEED
	else:
		target_speed = 0.0
	
	# Apply acceleration/deceleration
	var acceleration_rate = ACCELERATION if is_grounded else (ACCELERATION * AIR_CONTROL)
	var deceleration_rate = DECELERATION if is_grounded else (DECELERATION * AIR_CONTROL)
	
	if target_speed > 0.0:
		current_speed = lerp(current_speed, target_speed, acceleration_rate * delta)
	else:
		current_speed = lerp(current_speed, 0.0, deceleration_rate * delta)
	
	# Apply movement
	if input_direction.length() > 0.1:
		var movement_direction = input_direction.normalized()
		velocity_horizontal = Vector2(movement_direction.x, movement_direction.z) * current_speed
	else:
		velocity_horizontal = velocity_horizontal.lerp(Vector2.ZERO, deceleration_rate * delta)
	
	# Set player velocity
	player.velocity.x = velocity_horizontal.x
	player.velocity.z = velocity_horizontal.y

func apply_physics(delta: float):
	# Handle jumping
	if Input.is_key_pressed(KEY_SPACE) and is_grounded and jump_cooldown <= 0.0:
		player.velocity.y = JUMP_FORCE
		jump_cooldown = jump_delay
		print("COMPLEX JUMP! Force: ", JUMP_FORCE, " Velocity: ", player.velocity)
	
	# Update jump cooldown
	if jump_cooldown > 0.0:
		jump_cooldown -= delta
	
	# Apply gravity
	if not is_grounded:
		player.velocity.y -= gravity * delta
		# Clamp fall speed
		if player.velocity.y < -max_fall_speed:
			player.velocity.y = -max_fall_speed

func get_camera_relative_input() -> Vector3:
	var input_dir: Vector3 = Vector3.ZERO
	if Input.is_key_pressed(KEY_A):
		input_dir -= camera.global_transform.basis.x
	if Input.is_key_pressed(KEY_D):
		input_dir += camera.global_transform.basis.x
	if Input.is_key_pressed(KEY_W):
		input_dir -= camera.global_transform.basis.z
	if Input.is_key_pressed(KEY_S):
		input_dir += camera.global_transform.basis.z
	return input_dir

func debug_physics():
	# Only print when moving or jumping
	if velocity_horizontal.length() > 0.1 or not is_grounded:
		var status = "RUNNING" if is_running else "WALKING"
		var ground_status = "GROUNDED" if is_grounded else "AIRBORNE"
		var jump_status = " (Can Jump)" if jump_cooldown <= 0.0 else " (Jump Cooldown: %.1f)" % jump_cooldown
		
		print("COMPLEX PHYSICS! Status: ", status, " ", ground_status, 
			  " Speed: ", current_speed, 
			  " Target: ", target_speed, 
			  " H-Velocity: ", velocity_horizontal, 
			  " Y-Velocity: ", player.velocity.y,
			  jump_status)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			print("ESC pressed - exiting complex physics test")
			get_tree().quit()
