class_name CameraViewConfig
extends Resource

## Camera View Configuration Resource
## Defines camera settings for different view modes in a scene

@export_group("View Settings")
@export var view_name: String = "Default View"
@export var view_description: String = "Default camera view"

@export_group("SpringArm3D Settings")
@export var spring_length: float = 7.0
@export var collision_enabled: bool = true
@export var collision_margin: float = 0.04

@export_group("Camera Pivot Settings")
@export var pivot_offset: Vector3 = Vector3(0, 2.5, 0)
@export var pivot_rotation: Vector3 = Vector3(deg_to_rad(-15), 0, 0)

@export_group("Advanced Settings")
@export var smooth_transition: bool = true
@export var transition_speed: float = 2.0
@export var follow_player: bool = true

@export_group("Key Binding")
@export var key_binding: Key = KEY_1

func _init():
	resource_name = "Camera View Config"

func get_config_dictionary() -> Dictionary:
	"""Convert resource to dictionary format for SimpleCameraManager"""
	return {
		"view_name": view_name,
		"description": view_description,
		"spring_length": spring_length,
		"pivot_offset": pivot_offset,
		"pivot_rotation": pivot_rotation,
		"collision_enabled": collision_enabled,
		"collision_margin": collision_margin,
		"smooth_transition": smooth_transition,
		"transition_speed": transition_speed,
		"follow_player": follow_player,
		"key_binding": key_binding
	}

func apply_to_spring_arm(spring_arm: SpringArm3D, camera_pivot: Node3D):
	"""Apply this configuration to SpringArm3D and CameraPivot"""
	if not spring_arm or not camera_pivot:
		return false
	
	# Configure SpringArm3D
	spring_arm.spring_length = spring_length
	spring_arm.collision_mask = 1 if collision_enabled else 0
	spring_arm.margin = collision_margin
	
	# Configure CameraPivot
	camera_pivot.position = pivot_offset
	camera_pivot.rotation = pivot_rotation
	
	return true

func get_debug_info() -> String:
	"""Get debug information about this camera config"""
	return "CameraViewConfig[%s]: SpringLength=%.2f, Offset=%s, Rotation=%s" % [
		view_name, 
		spring_length, 
		pivot_offset, 
		Vector3(rad_to_deg(pivot_rotation.x), rad_to_deg(pivot_rotation.y), rad_to_deg(pivot_rotation.z))
	]
