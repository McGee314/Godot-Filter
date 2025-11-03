extends RefCounted
class_name GraphPathSegmentFactory

## SOLID: Single Responsibility - Creates path segments with proper terrain following
## Factory pattern for creating different types of path segments

func create_path_segment(start_pos: Vector3, end_pos: Vector3, config: BaseGraphConfig, parent: Node3D, segment_name: String) -> Node3D:
	"""
	Create a path segment between two points with terrain following
	
	Args:
		start_pos: Starting position
		end_pos: Ending position  
		config: BaseGraphConfig with path properties
		parent: Parent node to attach segment to
		segment_name: Name for the segment
		
	Returns:
		Node3D: The created path segment container
	"""
	GameLogger.debug("🔨 PathSegmentFactory: Creating segment '%s' from %s to %s" % [segment_name, start_pos, end_pos], "GraphSystem")
	GameLogger.debug("🔍 PathSegmentFactory: Parent node: %s (in tree: %s)" % [parent.name if parent else "null", parent.is_inside_tree() if parent else "false"], "GraphSystem")
	
	var segment_container = Node3D.new()
	segment_container.name = segment_name
	parent.add_child(segment_container)
	
	# Create visual path segment
	var visual_segment = _create_visual_segment(start_pos, end_pos, config)
	if visual_segment:
		GameLogger.debug("🔧 PathSegmentFactory: Adding visual segment to container...", "GraphSystem")
		segment_container.add_child(visual_segment)
		GameLogger.debug("✅ PathSegmentFactory: Visual segment added (in tree: %s)" % visual_segment.is_inside_tree(), "GraphSystem")
	
	# Create collision if enabled
	if config.collision_enabled:
		var collision_segment = _create_collision_segment(start_pos, end_pos, config)
		if collision_segment:
			GameLogger.debug("🔧 PathSegmentFactory: Adding collision segment to container...", "GraphSystem")
			segment_container.add_child(collision_segment)
			GameLogger.debug("✅ PathSegmentFactory: Collision segment added (in tree: %s)" % collision_segment.is_inside_tree(), "GraphSystem")
	
	GameLogger.info("✅ PathSegmentFactory: Created segment '%s'" % segment_name)
	return segment_container

func _create_visual_segment(start_pos: Vector3, end_pos: Vector3, config: BaseGraphConfig) -> MeshInstance3D:
	"""Create the visual mesh for a path segment"""
	var segment = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	
	# Calculate segment properties
	var direction = (end_pos - start_pos).normalized()
	var distance = start_pos.distance_to(end_pos)
	
	# Create a box mesh for the path segment
	box_mesh.size = Vector3(config.path_width, config.path_height, distance)
	segment.mesh = box_mesh
	
	# Create material
	var material = _create_path_material(config)
	segment.material_override = material
	
	# Position and orient the segment
	var mid_point = (start_pos + end_pos) / 2
	segment.name = "PathVisual"
	
	# IMPORTANT: Set position BEFORE adding to tree to avoid "not inside tree" errors
	segment.position = mid_point  # Use position instead of global_position
	
	# Store look_at target for after tree insertion
	segment.set_meta("look_at_target", end_pos)
	segment.set_meta("look_at_distance", distance)
	
	return segment

func _create_collision_segment(start_pos: Vector3, end_pos: Vector3, config: BaseGraphConfig) -> Area3D:
	"""Create collision area for a path segment"""
	var area = Area3D.new()
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	
	# Calculate collision properties
	var distance = start_pos.distance_to(end_pos)
	
	# Create collision box (slightly larger than visual)
	box_shape.size = Vector3(config.path_width + 1.0, config.path_height + 1.0, distance + 1.0)
	collision_shape.shape = box_shape
	
	area.add_child(collision_shape)
	
	# Position and orient the collision area
	var mid_point = (start_pos + end_pos) / 2
	area.name = "PathCollision"
	
	# IMPORTANT: Set position BEFORE adding to tree to avoid "not inside tree" errors
	area.position = mid_point  # Use position instead of global_position
	
	# Store look_at target for after tree insertion
	area.set_meta("look_at_target", end_pos)
	area.set_meta("look_at_distance", distance)
	
	return area

func _create_path_material(config: BaseGraphConfig) -> StandardMaterial3D:
	"""Create material for path segments"""
	var material = StandardMaterial3D.new()
	
	if config.path_material:
		# Use custom material if provided
		return config.path_material
	else:
		# Create default material
		material.albedo_color = config.path_color
		material.roughness = 0.8
		material.metallic = 0.1
		
		# Add some texture variation
		material.uv1_scale = Vector3(2.0, 1.0, 1.0)
	
	return material

func create_debug_marker(position: Vector3, parent: Node3D, marker_name: String, color: Color = Color.RED) -> MeshInstance3D:
	"""Create a debug marker at a position"""
	var marker = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.5
	sphere_mesh.height = 1.0
	
	marker.mesh = sphere_mesh
	marker.name = marker_name
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color * 0.3
	
	marker.material_override = material
	marker.global_position = position
	
	parent.add_child(marker)
	
	GameLogger.debug("🎯 PathSegmentFactory: Created debug marker '%s' at %s" % [marker_name, position])
	return marker
