extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var camera: Camera3D = $Player/Camera3D

var MOVE_SPEED: float = 8.0
var JUMP_SPEED: float = 3.0  # Increased for better jump feel
var gravity: float = 35.0    # Reduced gravity for smoother fall
var jump_cooldown: float = 0.0
var jump_delay: float = 0.3  # 300ms delay for more natural feel

func _ready():
	print("Simple player test initialized")
	print("Controls: WASD = Move, SPACE = Jump, ESC = Exit")

func _physics_process(delta: float):
	# Get input like the demo
	var direction: Vector3 = get_camera_relative_input()
	var h_veloc: Vector2 = Vector2(direction.x, direction.z).normalized() * MOVE_SPEED
	
	# Set velocity like the demo
	player.velocity.x = h_veloc.x
	player.velocity.z = h_veloc.y
	
	# Handle jumping with cooldown for smoother feel
	if Input.is_key_pressed(KEY_SPACE) and player.is_on_floor() and jump_cooldown <= 0.0:
		player.velocity.y = JUMP_SPEED + MOVE_SPEED * 0.016
		jump_cooldown = jump_delay
		print("JUMP! Velocity: ", player.velocity)
	
	# Update jump cooldown
	if jump_cooldown > 0.0:
		jump_cooldown -= delta
	
	# Apply gravity like the demo
	player.velocity.y -= gravity * delta
	
	# Move like the demo
	player.move_and_slide()
	
	# Simple logging with jump status
	if player.is_on_floor():
		if player.velocity.length() > 0.1:
			var jump_status = " (Can Jump)" if jump_cooldown <= 0.0 else " (Jump Cooldown: %.1f)" % jump_cooldown
			print("MOVING! Position: ", player.global_position, " Velocity: ", player.velocity, jump_status)
		else:
			var jump_status = " (Can Jump)" if jump_cooldown <= 0.0 else " (Jump Cooldown: %.1f)" % jump_cooldown
			print("GROUNDED! Position: ", player.global_position, " Velocity: ", player.velocity, jump_status)
	else:
		print("Falling: velocity.y=", player.velocity.y, " position=", player.global_position)

# Returns the input vector relative to the camera - exactly like demo
func get_camera_relative_input() -> Vector3:
	var input_dir: Vector3 = Vector3.ZERO
	if Input.is_key_pressed(KEY_A): # Left
		input_dir -= camera.global_transform.basis.x
	if Input.is_key_pressed(KEY_D): # Right
		input_dir += camera.global_transform.basis.x
	if Input.is_key_pressed(KEY_W): # Forward
		input_dir -= camera.global_transform.basis.z
	if Input.is_key_pressed(KEY_S): # Backward
		input_dir += camera.global_transform.basis.z
	return input_dir

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			print("ESC pressed - exiting scene")
			get_tree().quit()
