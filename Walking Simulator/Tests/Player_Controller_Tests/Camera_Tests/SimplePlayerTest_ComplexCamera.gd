extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var camera_pivot: Node3D = $Player/CameraPivot
@onready var camera_arm: SpringArm3D = $Player/CameraPivot/CameraArm
@onready var camera: Camera3D = $Player/CameraPivot/CameraArm/Camera3D

# Simple movement settings (from working simple version)
var MOVE_SPEED: float = 6.0  # Reduced for better feel
var JUMP_SPEED: float = 3.0
var gravity: float = 35.0
var jump_cooldown: float = 0.0
var jump_delay: float = 0.3

# Complex camera settings (adjusted for better feel)
var mouse_sensitivity: float = 0.001  # Reduced from 0.002
var camera_distance: float = 6.0
var camera_height: float = 2.0
var camera_smoothness: float = 4.0    # Reduced from 8.0
var max_pitch: float = 70.0
var min_pitch: float = -30.0

# Camera variables
var camera_rotation: Vector2 = Vector2.ZERO
var target_camera_rotation: Vector2 = Vector2.ZERO

func _ready():
	print("Complex Camera Test initialized")
	print("Testing: Simple physics + Complex camera + Direct input")
	print("Controls: WASD = Move, SPACE = Jump, Mouse = Look, ESC = Exit")
	
	# Setup camera
	setup_camera()
	
	# Capture mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func setup_camera():
	# Position camera arm
	camera_arm.spring_length = camera_distance
	camera_arm.position.y = camera_height
	
	print("Camera setup complete - Distance: ", camera_distance, " Height: ", camera_height)

func _input(event):
	# Mouse look
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		target_camera_rotation.x -= event.relative.y * mouse_sensitivity
		target_camera_rotation.y -= event.relative.x * mouse_sensitivity
		
		# Clamp pitch
		target_camera_rotation.x = clamp(target_camera_rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	
	# Toggle mouse capture
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_TAB:
			toggle_mouse_capture()
		elif event.keycode == KEY_ESCAPE:
			print("ESC pressed - exiting complex camera test")
			get_tree().quit()

func toggle_mouse_capture():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		print("Mouse released")
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		print("Mouse captured")

func _physics_process(delta: float):
	# Handle movement (simple version that works)
	handle_movement(delta)
	
	# Handle camera (complex version)
	handle_camera(delta)

func handle_movement(delta: float):
	# Get input direction relative to camera
	var direction: Vector3 = get_camera_relative_input()
	var h_veloc: Vector2 = Vector2(direction.x, direction.z).normalized() * MOVE_SPEED
	
	# Set horizontal velocity
	player.velocity.x = h_veloc.x
	player.velocity.z = h_veloc.y
	
	# Handle jumping with cooldown
	if Input.is_key_pressed(KEY_SPACE) and player.is_on_floor() and jump_cooldown <= 0.0:
		player.velocity.y = JUMP_SPEED
		jump_cooldown = jump_delay
		print("JUMP! Velocity: ", player.velocity)
	
	# Update jump cooldown
	if jump_cooldown > 0.0:
		jump_cooldown -= delta
	
	# Apply gravity
	player.velocity.y -= gravity * delta
	
	# Move
	player.move_and_slide()
	
	# Debug output
	if direction.length() > 0.1:
		print("MOVING! Direction: ", direction, " Velocity: ", player.velocity, " Position: ", player.global_position)

func handle_camera(delta: float):
	# Smooth camera rotation
	camera_rotation = camera_rotation.lerp(target_camera_rotation, camera_smoothness * delta)
	
	# Apply rotation to camera pivot
	camera_pivot.rotation.y = camera_rotation.y
	camera_pivot.rotation.x = camera_rotation.x
	
	# Debug camera info (reduced frequency)
	if Engine.get_process_frames() % 60 == 0:  # Every 60 frames
		print("Camera rotation: ", rad_to_deg(camera_rotation), " Target: ", rad_to_deg(target_camera_rotation))

func get_camera_relative_input() -> Vector3:
	var input_dir: Vector3 = Vector3.ZERO
	
	# Get camera's forward and right vectors (from pivot)
	var camera_forward = -camera_pivot.global_transform.basis.z
	var camera_right = camera_pivot.global_transform.basis.x
	
	# Remove Y component and normalize
	camera_forward.y = 0
	camera_right.y = 0
	camera_forward = camera_forward.normalized()
	camera_right = camera_right.normalized()
	
	# Apply input
	if Input.is_key_pressed(KEY_W):
		input_dir += camera_forward
	if Input.is_key_pressed(KEY_S):
		input_dir -= camera_forward
	if Input.is_key_pressed(KEY_A):
		input_dir -= camera_right
	if Input.is_key_pressed(KEY_D):
		input_dir += camera_right
	
	return input_dir
