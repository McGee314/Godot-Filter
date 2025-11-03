class_name PlayerCameraView
extends CameraViewBase

## Player Camera View - Default third-person view (SOLID: Single Responsibility)
## Handles only the normal player following camera behavior

func _init():
	view_name = "PlayerView"
	view_description = "Normal Player View"
	transition_speed = 3.0

func calculate_target_position() -> Vector3:
	"""Calculate camera position behind and above player"""
	var player_pos = get_player_position()
	
	if not player:
		return Vector3(0, 5, 10)  # Default fallback position
	
	# Get player's forward direction
	var player_forward = -player.global_transform.basis.z
	var player_right = player.global_transform.basis.x
	
	# Position camera behind and above player
	var distance = 7.0
	var height = 2.5
	var side_offset = 0.0  # Can add slight side offset if needed
	
	var camera_pos = player_pos
	camera_pos += player_forward * -distance  # Behind player
	camera_pos += Vector3.UP * height         # Above player
	camera_pos += player_right * side_offset  # Side offset
	
	return camera_pos

func calculate_target_rotation() -> Vector3:
	"""Calculate camera rotation to look at player area"""
	if not player:
		return Vector3.ZERO
	
	var player_pos = get_player_position()
	var look_target = player_pos + Vector3.UP * 1.5  # Look slightly above player
	
	# Calculate rotation to look at target
	var look_direction = (look_target - target_position).normalized()
	var rotation_y = atan2(look_direction.x, look_direction.z)
	var rotation_x = -asin(look_direction.y)
	
	return Vector3(rotation_x, rotation_y, 0)

func on_view_activated():
	"""Player view specific activation"""
	super.on_view_activated()
	GameLogger.info("🚶 Player view activated - Following player movement")

func on_view_deactivated():
	"""Player view specific deactivation"""
	super.on_view_deactivated()
	GameLogger.info("🚶 Player view deactivated")
