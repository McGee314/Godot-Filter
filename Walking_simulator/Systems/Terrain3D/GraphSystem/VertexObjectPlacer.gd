extends RefCounted
class_name GraphVertexObjectPlacer

## SOLID: Single Responsibility - Places objects at graph vertices
## Handles NPCs, artifacts, items, and decorations with proper positioning

func place_object(scene: PackedScene, position: Vector3, vertex_config: GraphVertexConfig, parent: Node3D, object_name: String) -> Node3D:
	"""
	Place an object at a vertex position
	
	Args:
		scene: PackedScene to instantiate
		position: World position to place object
		vertex_config: GraphVertexConfig with placement settings
		parent: Parent node to attach object to
		object_name: Name for the placed object
		
	Returns:
		Node3D: The instantiated object, or null if failed
	"""
	GameLogger.debug("🎯 VertexObjectPlacer: Placing object '%s' at %s" % [object_name, position])
	
	if not scene:
		GameLogger.warning("⚠️ VertexObjectPlacer: No scene provided for %s" % object_name)
		return null
	
	var instance = scene.instantiate()
	if not instance:
		GameLogger.error("❌ VertexObjectPlacer: Failed to instantiate scene for %s" % object_name)
		return null
	
	# Set basic properties
	instance.name = object_name
	parent.add_child(instance)
	
	# Apply positioning
	instance.global_position = position + Vector3(0, vertex_config.height_offset, 0)
	
	# Apply scaling
	if vertex_config.scale_variation > 0:
		var scale_factor = 1.0 + randf_range(-vertex_config.scale_variation, vertex_config.scale_variation)
		instance.scale = vertex_config.object_scale * scale_factor
	else:
		instance.scale = vertex_config.object_scale
	
	# Apply rotation
	if vertex_config.rotation_random:
		var random_rotation = randf_range(0, deg_to_rad(vertex_config.rotation_range))
		instance.rotation.y = random_rotation
	
	GameLogger.info("✅ VertexObjectPlacer: Placed object '%s' successfully" % object_name)
	return instance

func place_objects_at_vertex(position: Vector3, vertex_config: GraphVertexConfig, parent: Node3D, vertex_index: int) -> Array[Node3D]:
	"""
	Place multiple objects at a vertex based on configuration
	
	Args:
		position: World position of the vertex
		vertex_config: Configuration for object placement
		parent: Parent node to attach objects to
		vertex_index: Index of the vertex (for naming)
		
	Returns:
		Array[Node3D]: Array of placed objects
	"""
	var placed_objects: Array[Node3D] = []
	
	if not vertex_config.place_objects:
		GameLogger.debug("🚫 VertexObjectPlacer: Object placement disabled for vertex %d" % vertex_index)
		return placed_objects
	
	# Check spawn probability
	if randf() > vertex_config.spawn_probability:
		GameLogger.debug("🎲 VertexObjectPlacer: Spawn probability check failed for vertex %d" % vertex_index)
		return placed_objects
	
	GameLogger.info("🎯 VertexObjectPlacer: Placing objects at vertex %d" % vertex_index)
	
	var objects_placed = 0
	var max_objects = vertex_config.max_objects_per_vertex
	
	# Try to place objects based on available scenes and types
	for object_type in vertex_config.object_types:
		if objects_placed >= max_objects:
			break
		
		var scene = _get_scene_for_object_type(object_type, vertex_config)
		if scene:
			var object_name = "Vertex_%d_Object_%d" % [vertex_index, objects_placed]
			var placed_object = place_object(scene, position, vertex_config, parent, object_name)
			
			if placed_object:
				placed_objects.append(placed_object)
				objects_placed += 1
	
	GameLogger.info("✅ VertexObjectPlacer: Placed %d objects at vertex %d" % [objects_placed, vertex_index])
	return placed_objects

func _get_scene_for_object_type(object_type: int, vertex_config: GraphVertexConfig) -> PackedScene:
	"""Get a scene for the specified object type"""
	# This is a simplified version - in a full implementation, this would
	# select from the appropriate scene arrays based on object type
	
	match object_type:
		0: # NPC
			if vertex_config.npc_scenes.size() > 0:
				return vertex_config.npc_scenes[randi() % vertex_config.npc_scenes.size()]
		1: # ARTIFACT
			if vertex_config.artifact_scenes.size() > 0:
				return vertex_config.artifact_scenes[randi() % vertex_config.artifact_scenes.size()]
		2: # ITEM
			if vertex_config.item_scenes.size() > 0:
				return vertex_config.item_scenes[randi() % vertex_config.item_scenes.size()]
		3: # MARKER
			if vertex_config.marker_scenes.size() > 0:
				return vertex_config.marker_scenes[randi() % vertex_config.marker_scenes.size()]
		4: # DECORATION
			if vertex_config.decoration_scenes.size() > 0:
				return vertex_config.decoration_scenes[randi() % vertex_config.decoration_scenes.size()]
	
	GameLogger.debug("⚠️ VertexObjectPlacer: No scene available for object type %d" % object_type)
	return null

func create_debug_vertex_marker(position: Vector3, parent: Node3D, vertex_index: int, color: Color = Color.GREEN) -> MeshInstance3D:
	"""Create a debug marker for a vertex"""
	var marker = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 1.0
	sphere_mesh.height = 2.0
	
	marker.mesh = sphere_mesh
	marker.name = "VertexMarker_%d" % vertex_index
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color * 0.5
	
	marker.material_override = material
	marker.global_position = position
	
	parent.add_child(marker)
	
	GameLogger.debug("🎯 VertexObjectPlacer: Created debug marker for vertex %d at %s" % [vertex_index, position])
	return marker
