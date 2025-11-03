extends RefCounted
class_name BaseGraph

## Abstract base class for all graph-based path generation systems
## Follows graph theory principles and SOLID design patterns

signal graph_generation_started(config: BaseGraphConfig)
signal graph_generation_completed(vertex_count: int, edge_count: int)
signal graph_generation_failed(error_message: String)

enum GraphType {
	CYCLE,    # Simple cycle graph (vertices connected in ring)
	WHEEL,    # Wheel graph (cycle + center hub with spokes)
	STAR,     # Star graph (center hub with spokes, no outer ring)
	COMPLETE, # Complete graph (every vertex connected to every other)
	TREE,     # Tree graph (connected acyclic graph)
	PATH      # Path graph (linear sequence of vertices)
}

# Graph properties
var vertices: Array[Vector3] = []
var edges: Array[GraphEdge] = []
var graph_config: BaseGraphConfig
var terrain_sampler: GraphTerrainHeightSampler
var path_factory: GraphPathSegmentFactory
var vertex_placer: GraphVertexObjectPlacer

# Abstract methods - must be implemented by subclasses
func _get_graph_type() -> GraphType:
	push_error("BaseGraph._get_graph_type() must be implemented by subclass")
	return GraphType.CYCLE

func _calculate_vertices(center: Vector3, radius: float, vertex_count: int) -> Array[Vector3]:
	push_error("BaseGraph._calculate_vertices() must be implemented by subclass")
	return []

func _calculate_edges() -> Array[GraphEdge]:
	push_error("BaseGraph._calculate_edges() must be implemented by subclass")
	return []

func _validate_graph_properties() -> bool:
	"""Base validation that all graph types should pass"""
	# Check basic graph properties
	if vertices.is_empty():
		GameLogger.graph_error("❌ BaseGraph: No vertices generated")
		return false
	
	if not graph_config:
		GameLogger.graph_error("❌ BaseGraph: No graph configuration")
		return false
	
	# Basic sanity checks
	if vertices.size() < 2:
		GameLogger.graph_error("❌ BaseGraph: Need at least 2 vertices, got %d" % vertices.size())
		return false
	
	# Debug info for troubleshooting
	GameLogger.debug("🔍 BaseGraph validation: %d vertices, %d edges, config: %s" % [vertices.size(), edges.size(), graph_config != null], "GraphSystem")
	
	return true

# Concrete methods - shared by all graph types
func initialize(config: BaseGraphConfig):
	"""Initialize the graph with configuration"""
	if not config or not config.validate_configuration():
		push_error("Invalid graph configuration")
		return false
	
	graph_config = config
	terrain_sampler = GraphTerrainHeightSampler.new()
	path_factory = GraphPathSegmentFactory.new()
	vertex_placer = GraphVertexObjectPlacer.new()
	
	GameLogger.info("🔷 Initialized %s graph" % GraphType.keys()[_get_graph_type()], "GraphSystem")
	return true

func generate_graph(parent_node: Node3D) -> bool:
	"""Generate the complete graph structure"""
	GameLogger.info("🎯 [BaseGraph Debug] generate_graph() called with parent: %s" % (parent_node.name if parent_node else "null"), "GraphSystem")
	
	if not graph_config:
		var error = "Graph not initialized - call initialize() first"
		GameLogger.graph_error("❌ [BaseGraph Debug] %s" % error)
		graph_generation_failed.emit(error)
		return false
	
	GameLogger.info("🚀 [BaseGraph Debug] Generating %s graph..." % GraphType.keys()[_get_graph_type()], "GraphSystem")
	GameLogger.info("📊 [BaseGraph Debug] Config: center=%s, radius=%s, vertices=%d" % [graph_config.center_position, graph_config.radius, graph_config.vertex_count], "GraphSystem")
	graph_generation_started.emit(graph_config)
	
	# Clear previous data
	GameLogger.info("🧹 [BaseGraph Debug] Clearing previous data..." % [], "GraphSystem")
	vertices.clear()
	edges.clear()
		
	# Calculate graph structure
	GameLogger.info("📐 [BaseGraph Debug] Calculating vertices..." % [], "GraphSystem")
	vertices = _calculate_vertices(
		graph_config.center_position,
		graph_config.radius,
		graph_config.vertex_count
	)
	GameLogger.info("✅ [BaseGraph Debug] Calculated %d vertices" % vertices.size(), "GraphSystem")
		
	GameLogger.info("🔗 [BaseGraph Debug] Calculating edges..." % [], "GraphSystem")
	edges = _calculate_edges()
	GameLogger.info("✅ [BaseGraph Debug] Calculated %d edges" % edges.size(), "GraphSystem")
		
	# Validate graph properties
	GameLogger.info("✅ [BaseGraph Debug] Validating graph properties..." % [], "GraphSystem")
	if not _validate_graph_properties():
		var error = "Graph validation failed"
		GameLogger.graph_error("❌ [BaseGraph Debug] %s" % error)
		graph_generation_failed.emit(error)
		return false
		
	# Apply terrain height sampling
	_apply_terrain_heights()
		
	# Create visual representation
	var success = _create_visual_graph(parent_node)
		
	if success:
		# Apply look_at orientations after nodes are in tree
		_apply_post_tree_orientations(parent_node)
		
		GameLogger.info("✅ %s graph generated: %d vertices, %d edges" % [
			GraphType.keys()[_get_graph_type()], vertices.size(), edges.size()
		], "GraphSystem")
		graph_generation_completed.emit(vertices.size(), edges.size())
		return true
	else:
		var error = "Failed to create visual representation"
		GameLogger.graph_error("❌ BaseGraph: %s" % error)
		graph_generation_failed.emit(error)
		return false
			

func _apply_terrain_heights():
	"""Apply terrain height sampling to all vertices"""
	if not graph_config.follow_terrain_height or not terrain_sampler:
		return
	
	for i in range(vertices.size()):
		var vertex = vertices[i]
		var terrain_height = terrain_sampler.sample_height_at_position(vertex)
		vertices[i] = Vector3(vertex.x, terrain_height + graph_config.height_offset, vertex.z)

func _apply_post_tree_orientations(parent_node: Node3D):
	"""Apply look_at orientations after nodes are added to scene tree"""
	GameLogger.debug("🔧 Applying post-tree orientations to path segments...", "GraphSystem")
	
	if not parent_node:
		return
	
	# Find all nodes with look_at metadata
	var nodes_to_orient = []
	_find_nodes_with_orientation_metadata(parent_node, nodes_to_orient)
	
	GameLogger.debug("🔍 Found %d nodes requiring orientation" % nodes_to_orient.size(), "GraphSystem")
	
	for node in nodes_to_orient:
		if node.has_meta("look_at_target") and node.has_meta("look_at_distance"):
			var target = node.get_meta("look_at_target")
			var distance = node.get_meta("look_at_distance")
			
			if node.is_inside_tree() and distance > 0.001:
				# Apply look_at with error handling
				var direction = (target - node.global_position).normalized()
				if direction.length() > 0.001:
					# Use manual rotation to avoid look_at issues
					node.rotation.y = atan2(direction.x, direction.z)
					GameLogger.debug("✅ Applied orientation to %s" % node.name, "GraphSystem")
				else:
					GameLogger.graph_warning("⚠️ Zero direction vector for %s" % node.name)
			else:
				GameLogger.graph_warning("⚠️ Skipping orientation for %s (not in tree or zero distance)" % node.name)

func _find_nodes_with_orientation_metadata(node: Node, found_nodes: Array):
	"""Recursively find nodes that need orientation applied"""
	if node.has_meta("look_at_target"):
		found_nodes.append(node)
	
	for child in node.get_children():
		_find_nodes_with_orientation_metadata(child, found_nodes)

func _create_visual_graph(parent_node: Node3D) -> bool:
	"""Create visual representation of the graph"""
	# Create container
	var graph_container = Node3D.new()
	graph_container.name = "%sGraph_%s" % [
		GraphType.keys()[_get_graph_type()],
		graph_config.get_configuration_id()
	]
	parent_node.add_child(graph_container)
	
	# Create edges (paths)
	var edge_container = Node3D.new()
	edge_container.name = "Edges"
	graph_container.add_child(edge_container)
	
	for i in range(edges.size()):
		var edge = edges[i]
		var start_vertex = vertices[edge.start_index]
		var end_vertex = vertices[edge.end_index]
		
		path_factory.create_path_segment(
			start_vertex, end_vertex, graph_config, edge_container, 
			"Edge_%d_%d" % [edge.start_index, edge.end_index]
		)
	
	# Create vertices (objects)
	var vertex_container = Node3D.new()
	vertex_container.name = "Vertices"
	graph_container.add_child(vertex_container)
	
	_place_vertex_objects(vertex_container)
	
	return true

func _place_vertex_objects(container: Node3D):
	"""Place objects at vertices based on configuration"""
	if not graph_config.vertex_config or not graph_config.vertex_config.place_objects:
		return
	
	for i in range(vertices.size()):
		var vertex_pos = vertices[i]
		var objects_to_place = graph_config.vertex_config.get_objects_to_place()
		
		for j in range(objects_to_place.size()):
			var object_type = objects_to_place[j]
			var scene = graph_config.vertex_config.get_random_scene_for_type(object_type)
			
			if scene:
				vertex_placer.place_object(
					scene, vertex_pos, graph_config.vertex_config, container,
					"Vertex_%d_%s_%d" % [i, BaseGraphConfig.ObjectType.keys()[object_type], j]
				)

# Utility methods
func get_vertex_count() -> int:
	"""Get number of vertices in the graph"""
	return vertices.size()

func get_edge_count() -> int:
	"""Get number of edges in the graph"""
	return edges.size()

func get_vertex_position(index: int) -> Vector3:
	"""Get position of vertex at index"""
	if index >= 0 and index < vertices.size():
		return vertices[index]
	return Vector3.ZERO

func get_adjacent_vertices(vertex_index: int) -> Array[int]:
	"""Get indices of vertices adjacent to the given vertex"""
	var adjacent: Array[int] = []
	
	for edge in edges:
		if edge.start_index == vertex_index:
			adjacent.append(edge.end_index)
		elif edge.end_index == vertex_index:
			adjacent.append(edge.start_index)
	
	return adjacent

func is_graph_connected() -> bool:
	"""Check if the graph is connected (all vertices reachable)"""
	if vertices.size() <= 1:
		return true
	
	# Simple BFS to check connectivity
	var visited = {}
	var queue = [0]  # Start from vertex 0
	visited[0] = true
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var adjacent = get_adjacent_vertices(current)
		
		for neighbor in adjacent:
			if not visited.has(neighbor):
				visited[neighbor] = true
				queue.append(neighbor)
	
	return visited.size() == vertices.size()

# Edge class for representing graph connections
class GraphEdge:
	var start_index: int
	var end_index: int
	var weight: float = 1.0
	var edge_type: String = "default"
	
	func _init(start: int, end: int, w: float = 1.0, type: String = "default"):
		start_index = start
		end_index = end
		weight = w
		edge_type = type
	
	func get_length(vertices: Array[Vector3]) -> float:
		if start_index >= vertices.size() or end_index >= vertices.size():
			return 0.0
		return vertices[start_index].distance_to(vertices[end_index])
	
	func _to_string() -> String:
		return "Edge(%d -> %d, weight=%.2f, type=%s)" % [start_index, end_index, weight, edge_type]
