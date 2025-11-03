extends BaseGraph
class_name CycleGraph

## Cycle Graph implementation - vertices connected in a simple ring
## Examples: Triangle (C3), Square (C4), Pentagon (C5), Hexagon (C6)
## No center hub - just outer ring connections

func _get_graph_type() -> GraphType:
	return GraphType.CYCLE

func _calculate_vertices(center: Vector3, radius: float, vertex_count: int) -> Array[Vector3]:
	"""Calculate vertices arranged in a circle"""
	if not graph_config:
		return []
	
	return graph_config.calculate_vertex_positions(center, radius, vertex_count)

func _calculate_edges() -> Array[GraphEdge]:
	"""Calculate edges connecting vertices in a cycle"""
	var cycle_edges: Array[GraphEdge] = []
	
	if vertices.size() < 3:
		GameLogger.error("❌ CycleGraph: Need at least 3 vertices for a cycle")
		return cycle_edges
	
	# Create edges connecting each vertex to the next (forming a cycle)
	for i in range(vertices.size()):
		var next_index = (i + 1) % vertices.size()
		var edge = GraphEdge.new(i, next_index, 1.0, "cycle")
		cycle_edges.append(edge)
	
	GameLogger.debug("🔗 CycleGraph: Created %d cycle edges" % cycle_edges.size())
	return cycle_edges

func _validate_graph_properties() -> bool:
	"""Validate cycle graph properties"""
	# First call base validation
	if not super._validate_graph_properties():
		return false
	
	# A cycle graph should have exactly n vertices and n edges
	if vertices.size() != edges.size():
		GameLogger.error("❌ CycleGraph: Vertex count (%d) should equal edge count (%d)" % [vertices.size(), edges.size()])
		return false
	
	# Check minimum vertex count
	if vertices.size() < 3:
		GameLogger.error("❌ CycleGraph: Need at least 3 vertices, got %d" % vertices.size())
		return false
	
	# Verify connectivity (should form a single cycle)
	if not is_graph_connected():
		GameLogger.error("❌ CycleGraph: Graph is not connected")
		return false
	
	# Verify each vertex has exactly 2 neighbors (cycle property)
	for i in range(vertices.size()):
		var adjacent = get_adjacent_vertices(i)
		if adjacent.size() != 2:
			GameLogger.error("❌ CycleGraph: Vertex %d has %d neighbors (should have 2)" % [i, adjacent.size()])
			return false
	
	GameLogger.debug("✅ CycleGraph: Validation passed")
	return true

func get_cycle_length() -> float:
	"""Get total length of the cycle"""
	var total_length = 0.0
	
	for edge in edges:
		total_length += edge.get_length(vertices)
	
	return total_length

func get_vertex_angles() -> Array[float]:
	"""Get angles of vertices relative to center"""
	var angles: Array[float] = []
	var center = graph_config.center_position if graph_config else Vector3.ZERO
	
	for vertex in vertices:
		var direction = (vertex - center).normalized()
		var angle = atan2(direction.z, direction.x)
		angles.append(angle)
	
	return angles

func is_regular_polygon() -> bool:
	"""Check if the cycle forms a regular polygon"""
	if vertices.size() < 3:
		return false
	
	var center = graph_config.center_position if graph_config else Vector3.ZERO
	var expected_radius = graph_config.radius if graph_config else 0.0
	var tolerance = 0.1
	
	# Check if all vertices are equidistant from center
	for vertex in vertices:
		var distance = center.distance_to(vertex)
		if abs(distance - expected_radius) > tolerance:
			return false
	
	return true

func get_graph_description() -> String:
	"""Get description of this cycle graph"""
	var vertex_count = vertices.size()
	var shape_name = ""
	
	match vertex_count:
		3: shape_name = "Triangle"
		4: shape_name = "Square"
		5: shape_name = "Pentagon"
		6: shape_name = "Hexagon"
		7: shape_name = "Heptagon"
		8: shape_name = "Octagon"
		9: shape_name = "Enneagon"
		_: shape_name = "%d-gon" % vertex_count
	
	return "Cycle Graph C%d (%s)" % [vertex_count, shape_name]

