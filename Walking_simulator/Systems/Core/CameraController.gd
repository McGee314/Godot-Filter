extends Node

# Camera parameters
@export var look_sensitivity: float = 0.02
@export var min_pitch: float = -1.5
@export var max_pitch: float = 1.5
@export var smooth_rotation: bool = true
@export var rotation_smoothness: float = 10.0

# Camera references
@onready var camera: Camera3D
@onready var character_body: CharacterBody3D
var input_manager: Node

# Camera state
var current_rotation: Vector2 = Vector2.ZERO
var target_rotation: Vector2 = Vector2.ZERO

func _ready():
	# Get references
	character_body = get_parent() as CharacterBody3D
	if not character_body:
		push_error("CameraController must be a child of CharacterBody3D")
	
	camera = character_body.get_node("Camera3D") as Camera3D
	if not camera:
		push_error("Camera3D not found in character body")
	
	# Get reference to input manager
	input_manager = character_body.get_node("InputManager")
	if not input_manager:
		push_error("InputManager not found - please add it as a child of the character body")

func _process(delta: float):
	_handle_camera_input()
	_update_camera_rotation(delta)

func _handle_camera_input():
	if not input_manager:
		return
		
	var camera_input = input_manager.get_camera_input()
	
	if camera_input != Vector2.ZERO:
		target_rotation.x -= camera_input.y * look_sensitivity
		target_rotation.y -= camera_input.x * look_sensitivity
		
		# Clamp pitch
		target_rotation.x = clamp(target_rotation.x, min_pitch, max_pitch)

func _update_camera_rotation(delta: float):
	if smooth_rotation:
		# Smooth camera rotation
		current_rotation = current_rotation.lerp(target_rotation, rotation_smoothness * delta)
	else:
		current_rotation = target_rotation
	
	# Apply rotation to character body (Y rotation)
	character_body.rotation.y = current_rotation.y
	
	# Apply rotation to camera (X rotation)
	camera.rotation.x = current_rotation.x

func set_look_sensitivity(sensitivity: float):
	look_sensitivity = sensitivity

func set_pitch_limits(min_pitch_value: float, max_pitch_value: float):
	self.min_pitch = min_pitch_value
	self.max_pitch = max_pitch_value

func set_smooth_rotation(enabled: bool, smoothness: float = 10.0):
	smooth_rotation = enabled
	rotation_smoothness = smoothness

func get_camera() -> Camera3D:
	return camera

func get_current_rotation() -> Vector2:
	return current_rotation

func set_rotation(rotation: Vector2):
	target_rotation = rotation
	current_rotation = rotation

func reset_rotation():
	target_rotation = Vector2.ZERO
	current_rotation = Vector2.ZERO
