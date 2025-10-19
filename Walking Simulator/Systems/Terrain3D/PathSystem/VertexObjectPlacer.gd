extends RefCounted
class_name VertexObjectPlacer

## SOLID: Single Responsibility - Places objects at wheel graph vertices
## Handles NPCs, artifacts, items, and decorations with proper positioning

func place_object(scene: PackedScene, position: Vector3, vertex_config: VertexConfig, parent: Node3D, object_name: String) -> Node3D:
	"""
	Place an object at a vertex position
	
	Args:
		scene: PackedScene to instantiate
		position: World position to place object
		vertex_config: VertexConfig with placement settings
		parent: Parent node to attach object to
		object_name: Name for the placed object
		
	Returns:
		Node3D: The instantiated object, or null if failed
	"""
	if not scene:
		GameLogger.warning("⚠️ VertexObjectPlacer: No scene provided for %s" % object_name)
		return null
	
	var instance = scene.instantiate()
	if not instance:
		GameLogger.error("❌ VertexObjectPlacer: Failed to instantiate scene for %s" % object_name)
		return null
	
	# Set name
	instance.name = object_name
	
	# Apply transformations
	_apply_position(instance, position, vertex_config)
	_apply_scale(instance, vertex_config)
	_apply_rotation(instance, vertex_config)
	
	# Add to parent
	parent.add_child(instance)
	
	# Configure object based on type
	_configure_object_by_type(instance, vertex_config)
	
	GameLogger.debug("📍 Placed object: %s at %s" % [object_name, position])
	
	return instance

func _apply_position(instance: Node3D, position: Vector3, vertex_config: VertexConfig):
	"""Apply position with height offset"""
	var final_position = position
	final_position.y += vertex_config.height_offset
	instance.global_position = final_position

func _apply_scale(instance: Node3D, vertex_config: VertexConfig):
	"""Apply scale with random variation"""
	var scale = vertex_config.get_random_scale()
	instance.scale = scale

func _apply_rotation(instance: Node3D, vertex_config: VertexConfig):
	"""Apply rotation with random variation"""
	if vertex_config.rotation_random:
		var rotation_y = vertex_config.get_random_rotation()
		instance.rotation.y = rotation_y

func _configure_object_by_type(instance: Node3D, vertex_config: VertexConfig):
	"""Configure object based on its type and properties"""
	# Add object to appropriate groups for easy management
	if instance.has_method("set_cultural_theme"):
		for theme in vertex_config.cultural_filter:
			instance.call("set_cultural_theme", theme)
	
	# Configure NPCs
	if instance.has_signal("npc_interaction_started"):
		instance.add_to_group("npcs")
		instance.add_to_group("interactive_objects")
	
	# Configure artifacts
	if instance.has_signal("artifact_examined"):
		instance.add_to_group("artifacts")
		instance.add_to_group("interactive_objects")
	
	# Configure items
	if instance.has_signal("item_collected"):
		instance.add_to_group("collectible_items")
		instance.add_to_group("interactive_objects")
	
	# Configure markers
	if instance.has_method("set_marker_info"):
		instance.add_to_group("markers")

func place_multiple_objects(scenes: Array[PackedScene], positions: Array[Vector3], vertex_config: VertexConfig, parent: Node3D, name_prefix: String) -> Array[Node3D]:
	"""
	Place multiple objects at multiple positions
	
	Args:
		scenes: Array of PackedScenes to place
		positions: Array of positions to place objects at
		vertex_config: VertexConfig with placement settings
		parent: Parent node to attach objects to
		name_prefix: Prefix for object names
		
	Returns:
		Array[Node3D]: Array of placed objects
	"""
	var placed_objects: Array[Node3D] = []
	
	for i in range(positions.size()):
		var position = positions[i]
		var scene = scenes[i % scenes.size()] if not scenes.is_empty() else null
		
		if scene and vertex_config.should_place_object():
			var object_name = "%s_%d" % [name_prefix, i]
			var placed_object = place_object(scene, position, vertex_config, parent, object_name)
			if placed_object:
				placed_objects.append(placed_object)
	
	return placed_objects

func create_object_cluster(center_position: Vector3, cluster_radius: float, object_count: int, scenes: Array[PackedScene], vertex_config: VertexConfig, parent: Node3D, cluster_name: String) -> Array[Node3D]:
	"""
	Create a cluster of objects around a center position
	
	Args:
		center_position: Center of the cluster
		cluster_radius: Radius of the cluster
		object_count: Number of objects to place
		scenes: Array of scenes to choose from
		vertex_config: VertexConfig with placement settings
		parent: Parent node to attach objects to
		cluster_name: Name for the cluster
		
	Returns:
		Array[Node3D]: Array of placed objects
	"""
	var placed_objects: Array[Node3D] = []
	
	if scenes.is_empty():
		return placed_objects
	
	# Create cluster container
	var cluster_container = Node3D.new()
	cluster_container.name = cluster_name
	cluster_container.global_position = center_position
	parent.add_child(cluster_container)
	
	for i in range(object_count):
		if not vertex_config.should_place_object():
			continue
		
		# Generate random position within cluster radius
		var angle = randf() * 2.0 * PI
		var distance = randf() * cluster_radius
		var offset = Vector3(
			cos(angle) * distance,
			0,
			sin(angle) * distance
		)
		var object_position = center_position + offset
		
		# Sample terrain height for the position
		var terrain_sampler = TerrainHeightSampler.new()
		if terrain_sampler.is_terrain_available():
			object_position.y = terrain_sampler.get_terrain_height_at_position(object_position)
		
		# Select random scene
		var scene = scenes[randi() % scenes.size()]
		var object_name = "%s_Object_%d" % [cluster_name, i]
		
		var placed_object = place_object(scene, object_position, vertex_config, cluster_container, object_name)
		if placed_object:
			placed_objects.append(placed_object)
	
	return placed_objects

func remove_objects_in_group(parent: Node3D, group_name: String):
	"""Remove all objects in a specific group under the parent node"""
	var objects_to_remove: Array[Node] = []
	
	# Collect objects to remove
	_collect_objects_in_group_recursive(parent, group_name, objects_to_remove)
	
	# Remove collected objects
	for obj in objects_to_remove:
		if is_instance_valid(obj):
			obj.queue_free()
	
	GameLogger.info("🗑️ Removed %d objects from group '%s'" % [objects_to_remove.size(), group_name])

func _collect_objects_in_group_recursive(node: Node, group_name: String, collection: Array[Node]):
	"""Recursively collect objects in a group"""
	if node.is_in_group(group_name):
		collection.append(node)
	
	for child in node.get_children():
		_collect_objects_in_group_recursive(child, group_name, collection)

func get_objects_in_radius(center: Vector3, radius: float, parent: Node3D) -> Array[Node3D]:
	"""Get all objects within a radius of a center point"""
	var objects_in_radius: Array[Node3D] = []
	_collect_objects_in_radius_recursive(parent, center, radius, objects_in_radius)
	return objects_in_radius

func _collect_objects_in_radius_recursive(node: Node, center: Vector3, radius: float, collection: Array[Node3D]):
	"""Recursively collect objects within radius"""
	if node is Node3D:
		var node3d = node as Node3D
		var distance = node3d.global_position.distance_to(center)
		if distance <= radius:
			collection.append(node3d)
	
	for child in node.get_children():
		_collect_objects_in_radius_recursive(child, center, radius, collection)
