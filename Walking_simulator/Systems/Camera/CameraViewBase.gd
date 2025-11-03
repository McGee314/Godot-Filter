class_name CameraViewBase
extends Node3D

## Abstract base class for camera views (SOLID: Single Responsibility)
## Each camera view handles only its own positioning and behavior

signal view_changed(view_name: String)

# Abstract properties that must be implemented by concrete views
var view_name: String = "BaseView"
var view_description: String = "Base camera view"

# Common camera properties
var camera: Camera3D
var player: Node3D
var terrain_controller: Node3D
var transition_speed: float = 2.0

# Position and rotation targets
var target_position: Vector3
var target_rotation: Vector3

func _init():
	"""Initialize base view"""
	pass

## Abstract methods (must be implemented by concrete views)
func calculate_target_position() -> Vector3:
	"""Calculate where the camera should be positioned - OVERRIDE IN SUBCLASS"""
	push_error("calculate_target_position() must be implemented by subclass")
	return Vector3.ZERO

func calculate_target_rotation() -> Vector3:
	"""Calculate camera rotation - OVERRIDE IN SUBCLASS"""
	push_error("calculate_target_rotation() must be implemented by subclass")
	return Vector3.ZERO

func on_view_activated():
	"""Called when this view becomes active - OVERRIDE IN SUBCLASS"""
	GameLogger.info("📷 [%s] View activated" % view_name)

func on_view_deactivated():
	"""Called when switching away from this view - OVERRIDE IN SUBCLASS"""
	GameLogger.info("📷 [%s] View deactivated" % view_name)

## Common functionality (SOLID: DRY principle)
func setup_references(camera_ref: Camera3D, player_ref: Node3D, terrain_ref: Node3D):
	"""Setup common references used by all views"""
	camera = camera_ref
	player = player_ref
	terrain_controller = terrain_ref
	
	GameLogger.info("📷 [%s] References setup complete" % view_name)

func get_player_position() -> Vector3:
	"""Get current player position with terrain height"""
	if not player:
		return Vector3.ZERO
	
	var pos = player.global_position
	
	# Get terrain height if available
	if terrain_controller and terrain_controller.has_method("get_terrain_height_at_position"):
		var terrain_height = terrain_controller.get_terrain_height_at_position(pos)
		pos.y = terrain_height
	
	return pos

func get_scene_center() -> Vector3:
	"""Get scene center point"""
	# For now, use player position as scene center
	# In the future, this could be calculated from terrain bounds
	return get_player_position()

func update_targets():
	"""Update target position and rotation"""
	target_position = calculate_target_position()
	target_rotation = calculate_target_rotation()

func apply_smooth_transition(delta: float):
	"""Apply smooth camera movement to targets"""
	if not camera:
		return
	
	# Smooth position transition
	camera.global_position = camera.global_position.lerp(target_position, transition_speed * delta)
	
	# Smooth rotation transition
	camera.rotation = camera.rotation.lerp(target_rotation, transition_speed * delta)

## Utility methods
func deg_to_rad_vec(degrees: Vector3) -> Vector3:
	"""Convert degrees vector to radians vector"""
	return Vector3(deg_to_rad(degrees.x), deg_to_rad(degrees.y), deg_to_rad(degrees.z))

func get_view_info() -> Dictionary:
	"""Get information about this view"""
	return {
		"name": view_name,
		"description": view_description,
		"target_position": target_position,
		"target_rotation": target_rotation,
		"camera_position": camera.global_position if camera else Vector3.ZERO
	}
