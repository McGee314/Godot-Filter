class_name CanopyCameraView
extends CameraViewBase

## Canopy Camera View - Above forest level view (SOLID: Single Responsibility)
## Handles only the canopy level camera behavior for forest and path visualization

func _init():
	view_name = "CanopyView"
	view_description = "Canopy Level View"
	transition_speed = 2.5

func calculate_target_position() -> Vector3:
	"""Calculate camera position above forest canopy"""
	var player_pos = get_player_position()
	
	# Position camera above canopy level, following player
	var distance = 12.0
	var height = 20.0  # Above typical tree height
	var side_angle = 30.0  # Slight side angle for better view
	
	# Calculate offset position
	var offset_x = cos(deg_to_rad(side_angle)) * distance
	var offset_z = sin(deg_to_rad(side_angle)) * distance
	
	var camera_pos = player_pos
	camera_pos.x += offset_x
	camera_pos.z += offset_z
	camera_pos.y += height
	
	GameLogger.info("🌳 Canopy position calculated: %s (player: %s)" % [camera_pos, player_pos])
	return camera_pos

func calculate_target_rotation() -> Vector3:
	"""Calculate camera rotation to look down at player area"""
	var player_pos = get_player_position()
	
	# Look toward player area from canopy level
	var look_target = player_pos + Vector3.UP * 2.0  # Look slightly above ground
	var look_direction = (look_target - target_position).normalized()
	
	# Calculate rotation angles
	var rotation_y = atan2(look_direction.x, look_direction.z)
	var rotation_x = -asin(look_direction.y)  # Negative for looking down
	
	GameLogger.info("🌳 Canopy rotation calculated: X=%.1f°, Y=%.1f°" % [rad_to_deg(rotation_x), rad_to_deg(rotation_y)])
	return Vector3(rotation_x, rotation_y, 0)

func on_view_activated():
	"""Canopy view specific activation"""
	super.on_view_activated()
	GameLogger.info("🌳 Canopy view activated - Above forest level, following player")
	
	# Log what should be visible
	GameLogger.info("📍 This view should show:")
	GameLogger.info("  - Forest canopy and clearings")
	GameLogger.info("  - Hexagonal paths through trees")
	GameLogger.info("  - Player movement through forest")
	GameLogger.info("  - Asset placement in forest context")

func on_view_deactivated():
	"""Canopy view specific deactivation"""
	super.on_view_deactivated()
	GameLogger.info("🌳 Canopy view deactivated")

func get_canopy_height() -> float:
	"""Get typical forest canopy height for this terrain"""
	# Future enhancement: calculate based on actual tree heights
	# For now, return estimated Papua forest canopy height
	return 15.0

func adjust_height_for_terrain(base_height: float) -> float:
	"""Adjust camera height based on terrain elevation"""
	var player_pos = get_player_position()
	
	# Get terrain height at player position
	if terrain_controller and terrain_controller.has_method("get_terrain_height_at_position"):
		var terrain_height = terrain_controller.get_terrain_height_at_position(player_pos)
		return terrain_height + base_height
	
	return base_height

func is_player_in_forest() -> bool:
	"""Check if player is currently in forested area"""
	# Future enhancement: actual forest detection
	# For now, assume player is in forest (Papua is mostly forested)
	return true
