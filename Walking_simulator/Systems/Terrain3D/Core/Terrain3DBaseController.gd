extends Node3D
class_name Terrain3DBaseController

## Base Terrain3D Controller following SOLID principles
## Single Responsibility: Manages terrain operations
## Open/Closed: Can be extended for different terrain types
## Liskov Substitution: Concrete implementations can replace this base
## Interface Segregation: Provides minimal interface for terrain operations
## Dependency Inversion: Depends on abstractions, not concrete implementations

# Abstract interface - must be implemented by concrete classes
signal terrain_initialized
signal assets_placed(count: int)
signal terrain_cleared

var terrain3d_node: Terrain3D
var debug_config: Node
var terrain_stats: Dictionary = {}

# Protected methods that subclasses can override
func _get_terrain_type() -> String:
	"""Override this to return the specific terrain type"""
	assert(false, "_get_terrain_type() must be implemented by subclass")
	return ""

func _get_asset_pack_path() -> String:
	"""Override this to return the asset pack path for this terrain type"""
	assert(false, "_get_asset_pack_path() must be implemented by subclass")
	return ""

func _get_shared_assets_root() -> String:
	"""Override this to return the shared assets root path"""
	return "res://Assets/Terrain/Shared/"

func _get_shared_psx_models_path() -> String:
	"""Override this to return the PSX models path"""
	return "res://Assets/Terrain/Shared/psx_models/"

# Public interface - common to all terrain controllers
func initialize_terrain() -> bool:
	"""Initialize the terrain system - template method pattern"""
	GameLogger.info("🏗️ Initializing %s terrain..." % _get_terrain_type())
	
	if not _setup_terrain_references():
		return false
	
	if not _load_asset_pack():
		return false
	
	_initialize_stats()
	_setup_terrain_system()
	
	terrain_initialized.emit()
	GameLogger.info("✅ %s terrain initialized successfully" % _get_terrain_type())
	return true

func place_assets_near_player(radius: float = 30.0) -> int:
	"""Place assets near player position"""
	var player_pos = get_player_position()
	if player_pos == Vector3.ZERO:
		GameLogger.warning("⚠️ Could not get player position")
		return 0
	
	GameLogger.info("🎯 Placing %s assets near player at %s" % [_get_terrain_type(), player_pos])
	var count = _place_assets_around_position(player_pos, radius)
	assets_placed.emit(count)
	return count

func clear_all_assets() -> int:
	"""Clear all placed assets"""
	GameLogger.info("🧹 Clearing all %s assets..." % _get_terrain_type())
	var count = _clear_asset_containers()
	_reset_stats()
	terrain_cleared.emit()
	return count

func get_terrain_height_at_position(world_pos: Vector3) -> float:
	"""Get terrain height at world position"""
	if not terrain3d_node:
		return _get_fallback_height(world_pos)
	
	# Try multiple methods to get height
	if terrain3d_node.has_method("get_data") and terrain3d_node.get_data() != null:
		var terrain_data = terrain3d_node.get_data()
		if terrain_data.has_method("get_height"):
			var height = terrain_data.get_height(world_pos)
			if height != null and not is_nan(height):
				return height
	
	# Fallback to noise-based height
	return _get_fallback_height(world_pos)

func get_terrain_stats() -> Dictionary:
	"""Get current terrain statistics"""
	return terrain_stats.duplicate()

# Protected helper methods
func _setup_terrain_references() -> bool:
	"""Setup references to terrain nodes"""
	GameLogger.info("🔍 Searching for Terrain3D node...")
	GameLogger.info("📍 Current node path: %s" % get_path())
	
	var possible_paths = [
		"../../Terrain3DManager/Terrain3D",  # From PapuaTerrainController -> TerrainController -> root -> Terrain3DManager -> Terrain3D
		"../Terrain3DManager/Terrain3D",     # From child level
		"Terrain3DManager/Terrain3D",        # From root level
		"../Terrain3D",
		"Terrain3D"
	]
	
	terrain3d_node = null
	for path in possible_paths:
		GameLogger.info("🔍 Trying path: %s" % path)
		terrain3d_node = get_node_or_null(path)
		if terrain3d_node:
			GameLogger.info("✅ Found Terrain3D node at path: %s" % path)
			break
		else:
			GameLogger.info("❌ Terrain3D node not found at path: %s" % path)
	
	if not terrain3d_node:
		GameLogger.info("🔍 Trying find_child('Terrain3D')...")
		terrain3d_node = find_child("Terrain3D")
		if terrain3d_node:
			GameLogger.info("✅ Found Terrain3D node via find_child")
		else:
			GameLogger.info("❌ Terrain3D node not found via find_child")
	
	if not terrain3d_node:
		GameLogger.error("❌ Terrain3D node not found in scene - terrain features will not work")
		GameLogger.info("🔍 Scene tree structure:")
		_print_scene_tree(get_parent(), 0, 3)
	
	debug_config = get_node_or_null("/root/DebugConfig")
	return true

func _print_scene_tree(node: Node, depth: int, max_depth: int):
	"""Print scene tree structure for debugging"""
	if depth > max_depth:
		return
	
	var indent = ""
	for i in range(depth):
		indent += "  "
	
	if node:
		GameLogger.info("%s%s (%s)" % [indent, node.name, node.get_class()])
		for child in node.get_children():
			_print_scene_tree(child, depth + 1, max_depth)

func _load_asset_pack() -> bool:
	"""Load the asset pack - override in subclasses"""
	var asset_pack_path = _get_asset_pack_path()
	if not asset_pack_path.is_empty():
		var asset_pack = load(asset_pack_path)
		if asset_pack:
			GameLogger.info("✅ Loaded %s asset pack" % _get_terrain_type())
			return true
		else:
			GameLogger.error("❌ Failed to load asset pack: %s" % asset_pack_path)
	return false

func _initialize_stats():
	"""Initialize terrain statistics"""
	terrain_stats = {
		"trees": 0,
		"vegetation": 0,
		"mushrooms": 0,
		"stones": 0,
		"debris": 0,
		"total": 0
	}

func _setup_terrain_system():
	"""Setup terrain-specific systems - override in subclasses"""
	pass

func _place_assets_around_position(center: Vector3, radius: float) -> int:
	"""Place assets around a position - override in subclasses"""
	GameLogger.info("🎯 Placing assets around %s (radius: %.1f)" % [center, radius])
	return 0

func _clear_asset_containers() -> int:
	"""Clear asset containers - override in subclasses"""
	return 0

func _reset_stats():
	"""Reset terrain statistics"""
	_initialize_stats()

func _get_fallback_height(world_pos: Vector3) -> float:
	"""Get fallback height using noise"""
	var noise = FastNoiseLite.new()
	noise.seed = 12345
	noise.frequency = 0.01
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	return noise.get_noise_2d(world_pos.x, world_pos.z) * 20.0 + 5.0

func get_player_position() -> Vector3:
	"""Get the current player position"""
	var player = get_node_or_null("../../Player")  # From PapuaTerrainController -> TerrainController -> root -> Player
	if player:
		return player.global_position
	
	# Try alternative player paths
	var player_paths = ["../Player", "../PlayerController", "../PlayerRefactored", "Player"]
	for path in player_paths:
		player = get_node_or_null(path)
		if player:
			return player.global_position
	
	GameLogger.warning("⚠️ Could not find player node")
	GameLogger.info("🔍 Available nodes at scene root:")
	var scene_root = get_node_or_null("/root/PapuaScene_Terrain3D")
	if scene_root:
		for child in scene_root.get_children():
			GameLogger.info("  - %s (%s)" % [child.name, child.get_class()])
	return Vector3.ZERO

func generate_hexagonal_path_system():
	"""Generate hexagonal path system using new SOLID wheel graph system"""
	GameLogger.info("🔷 [%s] Starting hexagonal path system generation using SOLID architecture..." % _get_terrain_type())
	GameLogger.info("📊 System Analysis: Checking OOP graph system dependencies...")
	
	# Log system state for debugging
	GameLogger.info("🔍 System Status:")
	GameLogger.info("  - Current terrain type: %s" % _get_terrain_type())
	GameLogger.info("  - Player position: %s" % get_player_position())
	GameLogger.info("  - SOLID architecture components ready for initialization")
	
	# Get player position for centering
	var player_pos = get_player_position()
	if player_pos == Vector3.ZERO:
		GameLogger.warning("⚠️ Could not get player position, using default position")
		player_pos = Vector3(0, 0, 0)
	
	# Clear existing paths
	clear_existing_paths()
	
	# Initialize SOLID architecture components
	GameLogger.info("🏗️ Initializing SOLID architecture components...")
	
	# Create terrain height sampler
	GameLogger.info("🔧 Creating TerrainHeightSampler...")
	var terrain_sampler = TerrainHeightSampler.new()
	if terrain_sampler:
		terrain_sampler.set_fallback_height(player_pos.y)
		GameLogger.info("✅ TerrainHeightSampler created successfully")
	else:
		GameLogger.error("❌ Failed to create TerrainHeightSampler")
		return
	
	# Create path segment factory
	GameLogger.info("🔧 Creating PathSegmentFactory...")
	var path_factory = PathSegmentFactory.new()
	if path_factory:
		GameLogger.info("✅ PathSegmentFactory created successfully")
	else:
		GameLogger.error("❌ Failed to create PathSegmentFactory")
		return
	
	# Create vertex object placer
	GameLogger.info("🔧 Creating VertexObjectPlacer...")
	var vertex_placer = VertexObjectPlacer.new()
	if vertex_placer:
		GameLogger.info("✅ VertexObjectPlacer created successfully")
	else:
		GameLogger.error("❌ Failed to create VertexObjectPlacer")
		return
	
	GameLogger.info("✅ All SOLID components initialized successfully")
	
	GameLogger.info("⚙️ Preparing W5 pentagon configuration...")
	
	# Create and initialize standalone wheel graph generator
	GameLogger.info("🔄 Creating StandaloneWheelGraphGenerator using SOLID architecture...")
	var wheel_generator = StandaloneWheelGraphGenerator.new()
	if not wheel_generator:
		GameLogger.error("❌ Failed to create StandaloneWheelGraphGenerator")
		return
	
	GameLogger.info("🔗 Injecting SOLID dependencies into generator...")
	wheel_generator.initialize_with_dependencies(terrain_sampler, path_factory, vertex_placer)
	
	# Configure the wheel graph
	GameLogger.info("⚙️ Configuring W5 pentagon wheel graph...")
	var config_dict = {
		"path_width": 3.0,
		"path_height": 0.2,
		"path_color": Color(0.6, 0.4, 0.2),
		"create_spokes": true,
		"create_outer_ring": true,
		"follow_terrain_height": true
	}
	wheel_generator.configure_wheel_graph(player_pos, 25.0, 5, config_dict)
	
	# Generate the wheel graph
	GameLogger.info("🚀 Generating wheel graph using SOLID architecture...")
	var success = wheel_generator.generate_wheel_graph(self)
	
	if success:
		GameLogger.info("✅ Hexagonal path system generated successfully using SOLID architecture!")
		var stats = wheel_generator.get_statistics()
		GameLogger.info("📊 Graph Statistics:")
		GameLogger.info("  - Vertices: %d" % stats.vertices)
		GameLogger.info("  - Edges: %d" % stats.edges)
		GameLogger.info("  - Graph Type: W5 Pentagon Wheel Graph")
	else:
		GameLogger.error("❌ Failed to generate hexagonal path system using SOLID architecture")

func _get_wheel_graph_config_path() -> String:
	"""Get the appropriate wheel graph configuration path based on terrain type"""
	var terrain_type = _get_terrain_type().to_lower()
	
	match terrain_type:
		"papua":
			return "res://Resources/PathSystem/PapuaWheelGraphConfig.tres"
		"pasar":
			return "res://Resources/PathSystem/PasarWheelGraphConfig.tres"
		"tambora":
			return "res://Resources/PathSystem/TamboraWheelGraphConfig.tres"
		_:
			# Default to Papua config
			return "res://Resources/PathSystem/PapuaWheelGraphConfig.tres"

# Signal handlers for wheel graph generation
func _on_path_generation_started(config):
	"""Handle path generation started signal"""
	GameLogger.info("🚀 Path generation started: %s" % config.get_configuration_summary())

func _on_path_generation_completed(vertex_count: int, path_count: int):
	"""Handle path generation completed signal"""
	GameLogger.info("🎉 Path generation completed: %d vertices, %d paths" % [vertex_count, path_count])

func _on_path_generation_failed(error_message: String):
	"""Handle path generation failed signal"""
	GameLogger.error("💥 Path generation failed: %s" % error_message)

func clear_existing_paths():
	"""Clear all existing path systems"""
	var paths_to_remove = []
	for child in get_children():
		if child.name.contains("Path") or child.name.contains("Wheel") or child.name.contains("Hexagon"):
			paths_to_remove.append(child)
	
	for path in paths_to_remove:
		path.queue_free()
	
	if paths_to_remove.size() > 0:
		GameLogger.info("🧹 Cleared %d existing path systems" % paths_to_remove.size())

func place_demo_rock_assets():
	"""Place demo rock assets near player position using improved height sampling"""
	GameLogger.info("🪨 [%s] Placing demo rock assets near player position..." % _get_terrain_type())
	
	# Get player position
	var player_pos = get_player_position()
	if player_pos == Vector3.ZERO:
		GameLogger.warning("⚠️ Could not get player position, using default position")
		player_pos = Vector3(0, 0, 0)
	GameLogger.info("📍 Player position: %s" % player_pos)
	
	# Create rock container
	var rock_container = Node3D.new()
	rock_container.name = "DemoRocksNearPlayer"
	add_child(rock_container)
	
	# Get demo rock models
	var rock_paths = [
		"res://Assets/Terrain/Shared/demo_assets/models/RockA.tscn",
		"res://Assets/Terrain/Shared/demo_assets/models/RockB.tscn",
		"res://Assets/Terrain/Shared/demo_assets/models/RockC.tscn"
	]
	
	# Place rocks near the player
	var rock_count = 0
	for i in range(15):  # Place 15 rocks near player
		var rock_path = rock_paths[randi() % rock_paths.size()]
		if ResourceLoader.exists(rock_path):
			var rock_scene = load(rock_path)
			var rock_instance = rock_scene.instantiate()
			
			# Random position near the player
			var offset_x = randf_range(-25, 25)
			var offset_z = randf_range(-25, 25)
			var pos = player_pos + Vector3(offset_x, 0, offset_z)
			
			# Check if position is on a path - skip if it is
			if is_position_on_path(pos):
				continue
			
			# Use improved height sampling
			var terrain_height = get_terrain_height_at_position(pos)
			
			# Add to scene tree first, then set position
			rock_container.add_child(rock_instance)
			rock_instance.global_position = Vector3(pos.x, terrain_height, pos.z)
			rock_instance.rotation.y = randf() * TAU
			rock_instance.scale = Vector3(randf_range(0.5, 1.5), randf_range(0.5, 1.5), randf_range(0.5, 1.5))
			
			rock_count += 1
	
	GameLogger.info("✅ Placed %d demo rock assets near player with improved height sampling" % rock_count)

# Mountain border function moved to Research folder
# See: Systems/Terrain3D/Research/Terrain3DResearch.gd

func show_terrain3d_regions():
	"""Show information about Terrain3D regions"""
	GameLogger.info("🗺️ [%s] Showing Terrain3D regions..." % _get_terrain_type())
	if not terrain3d_node:
		GameLogger.error("❌ Terrain3D node not found - cannot show regions")
		return
	
	GameLogger.info("✅ Terrain3D node found - analyzing regions...")
	
	# Get terrain data
	var terrain_data = terrain3d_node.get_data()
	if not terrain_data:
		GameLogger.error("❌ Terrain3D data not found")
		return
	
	# Show basic terrain information
	GameLogger.info("📊 Terrain3D Region Information:")
	GameLogger.info("  - Terrain data type: %s" % terrain_data.get_class())
	# Note: get_size() and get_map_scale() may not exist in this Terrain3D version
	GameLogger.info("  - Terrain data available: %s" % (terrain_data != null))
	
	# Test region boundaries
	var test_positions = [
		Vector3(0, 0, 0),
		Vector3(50, 0, 50),
		Vector3(-50, 0, -50),
		Vector3(100, 0, 100),
		Vector3(-100, 0, -100)
	]
	
	GameLogger.info("🔍 Testing region boundaries at %d positions:" % test_positions.size())
	for i in range(test_positions.size()):
		var pos = test_positions[i]
		var height = terrain_data.get_height(pos)
		# Note: is_position_valid() may not exist in this Terrain3D version
		GameLogger.info("  Position %d: %s -> Height: %.2f" % [i+1, pos, height])
	
	# Create visual region markers
	create_region_markers(test_positions)
	
	GameLogger.info("✅ Terrain3D region analysis complete")

func create_region_markers(positions: Array):
	"""Create visual markers for region boundaries"""
	GameLogger.info("📍 Creating region markers for %d positions" % positions.size())
	
	# Create marker container
	var marker_container = Node3D.new()
	marker_container.name = "Terrain3DRegionMarkers"
	add_child(marker_container)
	
	for i in range(positions.size()):
		var pos = positions[i]
		var height = get_terrain_height_at_position(pos)
		
		# Create marker
		var marker = MeshInstance3D.new()
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius = 1.0
		sphere_mesh.height = 2.0
		marker.mesh = sphere_mesh
		
		# Create material
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0.2, 0.8, 1.0)  # Blue color
		material.emission = Color(0.1, 0.3, 0.5)
		marker.material_override = material
		
		marker.name = "RegionMarker_%d" % i
		marker_container.add_child(marker)
		marker.global_position = Vector3(pos.x, height + 1.0, pos.z)
		
		# Add label (optional - you can implement a 3D text system)
		GameLogger.info("✅ Created region marker %d at %s (height: %.2f)" % [i, pos, height])

func test_terrain_height_sampling():
	"""Test terrain height sampling at various positions"""
	GameLogger.info("📏 [%s] Testing terrain height sampling..." % _get_terrain_type())
	if not terrain3d_node:
		GameLogger.error("❌ Terrain3D node not found - cannot test height sampling")
		return
	
	# Test height sampling at various positions
	var test_positions = [
		Vector3(0, 0, 0),
		Vector3(10, 0, 10),
		Vector3(-10, 0, -10),
		Vector3(50, 0, 50),
		Vector3(-50, 0, -50)
	]
	
	GameLogger.info("🧪 Testing height sampling at %d positions:" % test_positions.size())
	for pos in test_positions:
		var height = get_terrain_height_at_position(pos)
		GameLogger.info("  Position %s: Height = %.2f" % [pos, height])

func is_debug_enabled(debug_type: String) -> bool:
	"""Check if specific debug type is enabled"""
	if debug_config and debug_config.has_method("get"):
		return debug_config.get("enable_%s_debug" % debug_type)
	return false

# Helper functions for hexagonal path system
func place_artifact_at_vertex(vertex_pos: Vector3, vertex_index: int, container: Node3D):
	"""Place an artifact at a hexagon vertex"""
	GameLogger.info("🏺 Placing artifact at vertex %d at position %s" % [vertex_index, vertex_pos])
	
	# Create a simple artifact marker (you can replace with actual artifact models)
	var artifact = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(2, 2, 2)
	artifact.mesh = box_mesh
	
	# Create material for the artifact
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.8, 0.2)  # Gold color
	material.emission = Color(0.2, 0.1, 0.0)
	artifact.material_override = material
	
	artifact.name = "Artifact_%d" % vertex_index
	container.add_child(artifact)
	artifact.global_position = vertex_pos
	
	GameLogger.info("✅ Placed artifact %d at %s" % [vertex_index, vertex_pos])

func create_hexagon_paths(vertices: Array, container: Node3D):
	"""Create visual paths between hexagon vertices"""
	GameLogger.info("🛤️ Creating hexagon paths between %d vertices" % vertices.size())
	
	# Create path container
	var path_meshes = Node3D.new()
	path_meshes.name = "PathMeshes"
	container.add_child(path_meshes)
	
	# Connect each vertex to the next one (forming a hexagon)
	for i in range(vertices.size()):
		var current_vertex = vertices[i]
		var next_vertex = vertices[(i + 1) % vertices.size()]
		
		# Create path segment
		create_path_segment(current_vertex, next_vertex, i, path_meshes)
	
	GameLogger.info("✅ Created %d path segments" % vertices.size())

func create_path_segment(start_pos: Vector3, end_pos: Vector3, segment_index: int, container: Node3D):
	"""Create a single path segment between two points"""
	var segment = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	
	# Calculate segment properties
	var direction = (end_pos - start_pos).normalized()
	var distance = start_pos.distance_to(end_pos)
	
	# Create a box mesh for the path segment
	box_mesh.size = Vector3(3, 0.2, distance)  # Wide but thin path
	
	segment.mesh = box_mesh
	
	# Create road material
	var road_material = create_road_material_for_paths()
	segment.material_override = road_material
	
	# Position and orient the segment - FIXED: Sample terrain height at midpoint
	var mid_point_xz = (start_pos + end_pos) / 2
	# Sample terrain height at the actual midpoint position
	var terrain_height_at_midpoint = get_terrain_height_at_position(mid_point_xz)
	var mid_point = Vector3(mid_point_xz.x, terrain_height_at_midpoint, mid_point_xz.z)
	
	# Add to container first, then set properties
	segment.name = "PathSegment_%d" % segment_index
	container.add_child(segment)
	
	# Now set position and rotation after adding to scene tree
	segment.global_position = mid_point
	var angle = atan2(direction.z, direction.x)
	segment.rotation.y = angle
	
	GameLogger.info("✅ Created path segment %d from %s to %s (terrain height: %.2f)" % [segment_index, start_pos, end_pos, terrain_height_at_midpoint])

func create_path_collision_data(vertices: Array, container: Node3D):
	"""Create collision data for the paths"""
	GameLogger.info("🔧 Creating path collision data for %d vertices" % vertices.size())
	
	# Create collision container
	var collision_container = Node3D.new()
	collision_container.name = "PathCollisions"
	container.add_child(collision_container)
	
	# Create collision areas for each path segment
	for i in range(vertices.size()):
		var current_vertex = vertices[i]
		var next_vertex = vertices[(i + 1) % vertices.size()]
		
		create_path_collision_area(current_vertex, next_vertex, i, collision_container)
	
	GameLogger.info("✅ Created path collision data")

func create_path_collision_area(start_pos: Vector3, end_pos: Vector3, segment_index: int, container: Node3D):
	"""Create a collision area for a path segment"""
	var area = Area3D.new()
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	
	# Calculate collision properties
	var direction = (end_pos - start_pos).normalized()
	var distance = start_pos.distance_to(end_pos)
	
	# Create collision box
	box_shape.size = Vector3(4, 2, distance)  # Slightly larger than visual path
	collision_shape.shape = box_shape
	
	area.add_child(collision_shape)
	
	# Position and orient the collision area - FIXED: Sample terrain height at midpoint
	var mid_point_xz = (start_pos + end_pos) / 2
	# Sample terrain height at the actual midpoint position
	var terrain_height_at_midpoint = get_terrain_height_at_position(mid_point_xz)
	var mid_point = Vector3(mid_point_xz.x, terrain_height_at_midpoint, mid_point_xz.z)
	
	# Add to container first, then set properties
	area.name = "PathCollision_%d" % segment_index
	container.add_child(area)
	
	# Now set position and rotation after adding to scene tree
	area.global_position = mid_point
	var angle = atan2(direction.z, direction.x)
	area.rotation.y = angle
	
	GameLogger.info("✅ Created collision area %d at terrain height %.2f" % [segment_index, terrain_height_at_midpoint])

func create_road_material_for_paths() -> StandardMaterial3D:
	"""Create a road/path material for hexagon paths"""
	GameLogger.info("🛤️ Creating road material for paths...")
	var road_material = StandardMaterial3D.new()
	
	# Make paths more visible with a distinct color
	road_material.albedo_color = Color(0.8, 0.6, 0.4)  # Light brown/beige for visibility
	road_material.emission = Color(0.1, 0.05, 0.02)   # Slight glow to make paths stand out
	
	# Try to use demo rock texture as road texture
	var rock_texture_path = "res://Assets/Terrain/Shared/demo_assets/textures/rock023_alb_ht.png"
	if ResourceLoader.exists(rock_texture_path):
		var rock_texture = load(rock_texture_path)
		road_material.albedo_texture = rock_texture
		GameLogger.info("✅ Applied rock texture as road: %s" % rock_texture_path)
	else:
		GameLogger.info("ℹ️ Using solid color road material for better visibility")
	
	# Set road material properties
	road_material.roughness = 0.8  # Slightly rough
	road_material.metallic = 0.0   # Not metallic
	
	return road_material

func is_position_on_path(_pos: Vector3) -> bool:
	"""Check if a position is on any existing path"""
	# Simple implementation - check if position is near any path segment
	# This is a placeholder - in a real implementation you'd check against actual path geometry
	return false
