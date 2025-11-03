class_name FarSideCameraView
extends CameraViewBase

## Far Side Camera View - High overview perspective (SOLID: Single Responsibility)
## Handles only the far side overview camera behavior for terrain visualization

func _init():
	view_name = "FarSideView"
	view_description = "Far Side Overview"
	transition_speed = 1.5  # Slower transition for dramatic effect

func calculate_target_position() -> Vector3:
	"""Calculate camera position for far side overview"""
	var scene_center = get_scene_center()
	
	# Position camera high and far from scene center
	var distance = 50.0
	var height = 30.0
	var angle_offset = 45.0  # Degrees around the scene
	
	# Calculate position in a diagonal offset from scene center
	var offset_x = cos(deg_to_rad(angle_offset)) * distance
	var offset_z = sin(deg_to_rad(angle_offset)) * distance
	
	var camera_pos = scene_center
	camera_pos.x += offset_x
	camera_pos.z += offset_z
	camera_pos.y += height
	
	GameLogger.info("🔭 Far side position calculated: %s (center: %s)" % [camera_pos, scene_center])
	return camera_pos

func calculate_target_rotation() -> Vector3:
	"""Calculate camera rotation to look down at scene center"""
	var scene_center = get_scene_center()
	
	# Look toward scene center from far side position
	var look_direction = (scene_center - target_position).normalized()
	
	# Calculate rotation angles
	var rotation_y = atan2(look_direction.x, look_direction.z)
	var rotation_x = -asin(look_direction.y)  # Negative for looking down
	
	GameLogger.info("🔭 Far side rotation calculated: X=%.1f°, Y=%.1f°" % [rad_to_deg(rotation_x), rad_to_deg(rotation_y)])
	return Vector3(rotation_x, rotation_y, 0)

func on_view_activated():
	"""Far side view specific activation"""
	super.on_view_activated()
	GameLogger.info("🔭 Far side view activated - Overview of hexagonal path system")
	
	# Log what should be visible
	GameLogger.info("📍 This view should show:")
	GameLogger.info("  - Complete hexagonal path pattern")
	GameLogger.info("  - All 6 golden artifacts at vertices")
	GameLogger.info("  - Terrain topology and forest distribution")
	GameLogger.info("  - Rock asset placement")

func on_view_deactivated():
	"""Far side view specific deactivation"""
	super.on_view_deactivated()
	GameLogger.info("🔭 Far side view deactivated")

func get_optimal_distance_for_terrain() -> float:
	"""Calculate optimal distance based on terrain size"""
	# Future enhancement: calculate based on actual terrain bounds
	# For now, return fixed distance
	return 50.0

func get_optimal_height_for_overview() -> float:
	"""Calculate optimal height for complete terrain overview"""
	# Future enhancement: calculate based on terrain height variation
	# For now, return fixed height
	return 30.0
