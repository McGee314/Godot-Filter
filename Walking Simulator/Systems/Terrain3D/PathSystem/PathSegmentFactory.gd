extends RefCounted
class_name PathSegmentFactory

## SOLID: Single Responsibility - Creates path segments with proper terrain following
## Factory pattern for creating different types of path segments

func create_path_segment(start_pos: Vector3, end_pos: Vector3, config: WheelGraphPathConfig, parent: Node3D, segment_name: String) -> Node3D:
	"""
	Create a path segment between two points with terrain following
	
	Args:
		start_pos: Starting position
		end_pos: Ending position  
		config: WheelGraphPathConfig with path properties
		parent: Parent node to attach segment to
		segment_name: Name for the segment
		
	Returns:
		Node3D: The created path segment container
	"""
	var segment_container = Node3D.new()
	segment_container.name = segment_name
	parent.add_child(segment_container)
	
	# Create visual path segment
	var visual_segment = _create_visual_segment(start_pos, end_pos, config)
	visual_segment.name = "Visual"
	segment_container.add_child(visual_segment)
	
	# Create collision if enabled
	if config.collision_enabled:
		var collision_segment = _create_collision_segment(start_pos, end_pos, config)
		collision_segment.name = "Collision"
		segment_container.add_child(collision_segment)
	
	GameLogger.debug("🛤️ Created path segment: %s (%.1fm)" % [segment_name, start_pos.distance_to(end_pos)])
	
	return segment_container

func _create_visual_segment(start_pos: Vector3, end_pos: Vector3, config: WheelGraphPathConfig) -> MeshInstance3D:
	"""Create the visual mesh for the path segment"""
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	
	# Calculate segment properties
	var direction = (end_pos - start_pos).normalized()
	var distance = start_pos.distance_to(end_pos)
	
	# Create mesh with proper dimensions
	box_mesh.size = Vector3(config.path_width, config.path_height, distance)
	mesh_instance.mesh = box_mesh
	
	# Apply material
	if config.path_material:
		mesh_instance.material_override = config.path_material
	else:
		mesh_instance.material_override = _create_default_path_material(config)
	
	# Position and orient the segment with terrain following
	_position_segment_with_terrain_following(mesh_instance, start_pos, end_pos, config)
	
	return mesh_instance

func _create_collision_segment(start_pos: Vector3, end_pos: Vector3, config: WheelGraphPathConfig) -> Area3D:
	"""Create collision area for the path segment"""
	var area = Area3D.new()
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	
	# Calculate collision properties
	var distance = start_pos.distance_to(end_pos)
	
	# Create collision box (slightly larger than visual)
	box_shape.size = Vector3(config.path_width + 1.0, config.path_height + 1.0, distance)
	collision_shape.shape = box_shape
	area.add_child(collision_shape)
	
	# Set collision layer
	area.collision_layer = config.collision_layer
	
	# Position and orient the collision area
	_position_segment_with_terrain_following(area, start_pos, end_pos, config)
	
	return area

func _position_segment_with_terrain_following(segment: Node3D, start_pos: Vector3, end_pos: Vector3, config: WheelGraphPathConfig):
	"""Position and orient segment with proper terrain following"""
	var direction = (end_pos - start_pos).normalized()
	var distance = start_pos.distance_to(end_pos)
	
	# Calculate midpoint with terrain height sampling
	var mid_point: Vector3
	if config.follow_terrain_height:
		mid_point = _calculate_terrain_following_midpoint(start_pos, end_pos, config)
	else:
		mid_point = (start_pos + end_pos) / 2.0
	
	# Add height offset
	mid_point.y += config.height_offset
	
	# Set position
	segment.global_position = mid_point
	
	# Calculate rotation to align with path direction
	if direction.length() > 0.001:  # Avoid division by zero
		var up_vector = Vector3.UP
		
		# If terrain conforming is enabled, calculate slope-aware up vector
		if config.terrain_conforming:
			up_vector = _calculate_terrain_normal(start_pos, end_pos)
		
		# Look along the path direction
		segment.look_at(segment.global_position + direction, up_vector)

func _calculate_terrain_following_midpoint(start_pos: Vector3, end_pos: Vector3, config: WheelGraphPathConfig) -> Vector3:
	"""Calculate midpoint that follows terrain height properly"""
	var mid_point = (start_pos + end_pos) / 2.0
	
	# Sample terrain height at the midpoint instead of averaging Y coordinates
	var terrain_sampler = TerrainHeightSampler.new()
	if terrain_sampler.is_terrain_available():
		mid_point.y = terrain_sampler.get_terrain_height_at_position(mid_point)
	else:
		# Fallback to averaging if no terrain available
		mid_point.y = (start_pos.y + end_pos.y) / 2.0
	
	return mid_point

func _calculate_terrain_normal(start_pos: Vector3, end_pos: Vector3) -> Vector3:
	"""Calculate terrain normal for slope conforming"""
	var terrain_sampler = TerrainHeightSampler.new()
	if not terrain_sampler.is_terrain_available():
		return Vector3.UP
	
	var mid_point = (start_pos + end_pos) / 2.0
	var normal = terrain_sampler.get_terrain_normal_at_position(mid_point)
	
	return normal

func _create_default_path_material(config: WheelGraphPathConfig) -> StandardMaterial3D:
	"""Create default material for path segments"""
	var material = StandardMaterial3D.new()
	material.albedo_color = config.path_color
	material.roughness = 0.8
	material.metallic = 0.0
	
	# Add some texture variation based on scene type
	match config.scene_type:
		WheelGraphPathConfig.SceneType.PAPUA:
			material.albedo_color = Color(0.6, 0.4, 0.2)  # Brown dirt path
		WheelGraphPathConfig.SceneType.PASAR:
			material.albedo_color = Color(0.7, 0.7, 0.6)  # Stone/concrete
		WheelGraphPathConfig.SceneType.TAMBORA:
			material.albedo_color = Color(0.4, 0.3, 0.3)  # Volcanic rock
		_:
			material.albedo_color = config.path_color
	
	return material

func create_debug_marker(position: Vector3, color: Color = Color.YELLOW, size: float = 1.0, parent: Node3D = null) -> MeshInstance3D:
	"""Create a debug marker at the specified position"""
	var marker = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = size * 0.5
	sphere_mesh.height = size
	marker.mesh = sphere_mesh
	
	# Create debug material
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.flags_unshaded = true
	marker.material_override = material
	
	marker.global_position = position
	
	if parent:
		parent.add_child(marker)
	
	return marker
