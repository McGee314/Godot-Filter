extends RefCounted
class_name StandaloneWheelGraphGenerator

## Standalone Wheel Graph Generator using SOLID principles
## Avoids complex inheritance to prevent parser issues while maintaining architecture

signal graph_generation_started()
signal graph_generation_completed(vertex_count: int, edge_count: int)
signal graph_generation_failed(error_message: String)

# SOLID dependencies
var terrain_sampler: GraphTerrainHeightSampler
var path_factory: GraphPathSegmentFactory
var vertex_placer: GraphVertexObjectPlacer

# Graph data
var vertices: Array[Vector3] = []
var edges: Array = []
var configuration: Dictionary = {}

func _init():
	"""Initialize the standalone wheel graph generator"""
	GameLogger.info("🔧 StandaloneWheelGraphGenerator: Initializing...")

func initialize_with_dependencies(sampler: GraphTerrainHeightSampler, factory: GraphPathSegmentFactory, placer: GraphVertexObjectPlacer):
	"""Initialize with SOLID dependencies"""
	GameLogger.info("🔗 StandaloneWheelGraphGenerator: Injecting dependencies...")
	terrain_sampler = sampler
	path_factory = factory
	vertex_placer = placer
	GameLogger.info("✅ Dependencies injected successfully")

func configure_wheel_graph(center_pos: Vector3, radius: float, vertex_count: int, config_dict: Dictionary = {}):
	"""Configure the wheel graph parameters"""
	GameLogger.info("⚙️ StandaloneWheelGraphGenerator: Configuring W%d wheel graph..." % vertex_count)
	
	configuration = {
		"center_position": center_pos,
		"radius": radius,
		"vertex_count": vertex_count,
		"path_width": config_dict.get("path_width", 3.0),
		"path_height": config_dict.get("path_height", 0.2),
		"path_color": config_dict.get("path_color", Color(0.6, 0.4, 0.2)),
		"create_spokes": config_dict.get("create_spokes", true),
		"create_outer_ring": config_dict.get("create_outer_ring", true),
		"follow_terrain_height": config_dict.get("follow_terrain_height", true)
	}
	
	GameLogger.info("✅ Configuration set: W%d, radius=%.1fm, center=%s" % [vertex_count, radius, center_pos])

func generate_wheel_graph(parent_node: Node3D) -> bool:
	"""Generate the wheel graph in the scene"""
	GameLogger.info("🚀 StandaloneWheelGraphGenerator: Starting graph generation...")
	graph_generation_started.emit()
	
	if not _validate_configuration():
		var error = "Invalid configuration"
		GameLogger.error("❌ %s" % error)
		graph_generation_failed.emit(error)
		return false
	
	if not _validate_dependencies():
		var error = "Missing dependencies"
		GameLogger.error("❌ %s" % error)
		graph_generation_failed.emit(error)
		return false
	
	# Clear previous data
	vertices.clear()
	edges.clear()
	
	# Generate vertices
	if not _generate_vertices():
		var error = "Failed to generate vertices"
		GameLogger.error("❌ %s" % error)
		graph_generation_failed.emit(error)
		return false
	
	# Generate edges
	if not _generate_edges():
		var error = "Failed to generate edges"
		GameLogger.error("❌ %s" % error)
		graph_generation_failed.emit(error)
		return false
	
	# Create visual representation
	if not _create_visual_graph(parent_node):
		var error = "Failed to create visual representation"
		GameLogger.error("❌ %s" % error)
		graph_generation_failed.emit(error)
		return false
	
	GameLogger.info("✅ Wheel graph generated successfully!")
	GameLogger.info("📊 Statistics: %d vertices, %d edges" % [vertices.size(), edges.size()])
	graph_generation_completed.emit(vertices.size(), edges.size())
	return true

func _validate_configuration() -> bool:
	"""Validate the graph configuration"""
	if configuration.is_empty():
		GameLogger.error("❌ No configuration provided")
		return false
	
	if configuration.vertex_count < 3:
		GameLogger.error("❌ Vertex count must be at least 3")
		return false
	
	if configuration.radius <= 0:
		GameLogger.error("❌ Radius must be positive")
		return false
	
	GameLogger.debug("✅ Configuration validation passed")
	return true

func _validate_dependencies() -> bool:
	"""Validate that all dependencies are available"""
	if not terrain_sampler:
		GameLogger.error("❌ GraphTerrainHeightSampler dependency missing")
		return false
	
	if not path_factory:
		GameLogger.error("❌ GraphPathSegmentFactory dependency missing")
		return false
	
	if not vertex_placer:
		GameLogger.error("❌ GraphVertexObjectPlacer dependency missing")
		return false
	
	GameLogger.debug("✅ Dependency validation passed")
	return true

func _generate_vertices() -> bool:
	"""Generate wheel graph vertices"""
	GameLogger.info("🎯 Generating vertices for W%d wheel graph..." % configuration.vertex_count)
	
	var center_pos = configuration.center_position
	var radius = configuration.radius
	var vertex_count = configuration.vertex_count
	
	# Add center vertex
	var center_height = center_pos.y
	if configuration.follow_terrain_height and terrain_sampler:
		center_height = terrain_sampler.sample_height_at_position(center_pos)
	
	var center_vertex = Vector3(center_pos.x, center_height, center_pos.z)
	vertices.append(center_vertex)
	GameLogger.debug("📍 Center vertex: %s" % center_vertex)
	
	# Add outer vertices in wheel pattern
	for i in range(vertex_count):
		var angle = i * (2.0 * PI / vertex_count)
		var x = center_pos.x + cos(angle) * radius
		var z = center_pos.z + sin(angle) * radius
		var y = center_pos.y
		
		# Sample terrain height if enabled
		if configuration.follow_terrain_height and terrain_sampler:
			y = terrain_sampler.sample_height_at_position(Vector3(x, center_pos.y, z))
		
		var outer_vertex = Vector3(x, y, z)
		vertices.append(outer_vertex)
		GameLogger.debug("📍 Outer vertex %d: %s" % [i, outer_vertex])
	
	GameLogger.info("✅ Generated %d vertices successfully" % vertices.size())
	return true

func _generate_edges() -> bool:
	"""Generate wheel graph edges"""
	GameLogger.info("🔗 Generating edges...")
	
	var center_vertex = vertices[0]
	var outer_vertices = vertices.slice(1)
	var vertex_count = configuration.vertex_count
	
	# Create spokes (center to outer vertices)
	if configuration.create_spokes:
		for i in range(outer_vertices.size()):
			var edge = {
				"start": center_vertex,
				"end": outer_vertices[i],
				"type": "spoke",
				"name": "Spoke_%d" % i
			}
			edges.append(edge)
			GameLogger.debug("🔗 Created spoke edge: %s" % edge.name)
	
	# Create outer ring (connecting outer vertices)
	if configuration.create_outer_ring:
		for i in range(outer_vertices.size()):
			var current_vertex = outer_vertices[i]
			var next_vertex = outer_vertices[(i + 1) % outer_vertices.size()]
			var edge = {
				"start": current_vertex,
				"end": next_vertex,
				"type": "ring",
				"name": "Ring_%d" % i
			}
			edges.append(edge)
			GameLogger.debug("🔗 Created ring edge: %s" % edge.name)
	
	GameLogger.info("✅ Generated %d edges successfully" % edges.size())
	return true

func _create_visual_graph(parent_node: Node3D) -> bool:
	"""Create visual representation of the graph"""
	GameLogger.info("🎨 Creating visual representation...")
	
	# Create container for the wheel graph
	var graph_container = Node3D.new()
	graph_container.name = "WheelGraph_W%d" % configuration.vertex_count
	parent_node.add_child(graph_container)
	
	# Create path segments for each edge
	for edge in edges:
		var segment_name = edge.name
		var start_pos = edge.start
		var end_pos = edge.end
		
		GameLogger.debug("🎨 Creating visual segment: %s" % segment_name)
		
		# Create simple path segment
		var segment = _create_path_segment(start_pos, end_pos, segment_name)
		if segment:
			graph_container.add_child(segment)
		else:
			GameLogger.warning("⚠️ Failed to create segment: %s" % segment_name)
	
	# Create debug markers for vertices if needed
	if GameLogger.debug_enabled:
		_create_debug_markers(graph_container)
	
	GameLogger.info("✅ Visual representation created successfully")
	return true

func _create_path_segment(start_pos: Vector3, end_pos: Vector3, segment_name: String) -> MeshInstance3D:
	"""Create a simple path segment"""
	var segment = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	
	# Calculate segment properties
	var distance = start_pos.distance_to(end_pos)
	if distance < 0.001:
		GameLogger.warning("⚠️ Zero-length segment: %s" % segment_name)
		return null
	
	# Create mesh
	box_mesh.size = Vector3(configuration.path_width, configuration.path_height, distance)
	segment.mesh = box_mesh
	
	# Create material
	var material = StandardMaterial3D.new()
	material.albedo_color = configuration.path_color
	material.roughness = 0.8
	segment.material_override = material
	
	# Position and orient
	var mid_point = (start_pos + end_pos) / 2.0
	segment.name = segment_name
	segment.global_position = mid_point
	segment.look_at(end_pos, Vector3.UP)
	
	return segment

func _create_debug_markers(parent: Node3D):
	"""Create debug markers for vertices"""
	GameLogger.debug("🎯 Creating debug markers...")
	
	for i in range(vertices.size()):
		var vertex = vertices[i]
		var marker = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = 0.5
		
		marker.mesh = sphere
		marker.name = "DebugMarker_%d" % i
		
		var material = StandardMaterial3D.new()
		material.albedo_color = Color.RED if i == 0 else Color.GREEN
		material.emission_enabled = true
		material.emission = material.albedo_color * 0.5
		marker.material_override = material
		
		marker.global_position = vertex
		parent.add_child(marker)

func get_statistics() -> Dictionary:
	"""Get graph statistics"""
	return {
		"vertices": vertices.size(),
		"edges": edges.size(),
		"configuration": configuration
	}
