extends BaseGraph
class_name WheelGraph

## Wheel Graph implementation - cycle graph + center hub with spokes
## Examples: W3, W4 (square), W5 (pentagon), W6 (hexagon), W7, W8, W9
## Contains both outer ring connections AND spokes from center to vertices

var center_vertex: Vector3

func _get_graph_type() -> GraphType:
	return GraphType.WHEEL

func _calculate_vertices(center: Vector3, radius: float, vertex_count: int) -> Array[Vector3]:
	"""Calculate vertices: center hub + outer ring"""
	if not graph_config:
		return []
	
	var all_vertices: Array[Vector3] = []
	
	# Add center vertex first
	center_vertex = center
	if graph_config.follow_terrain_height and terrain_sampler:
		center_vertex.y = terrain_sampler.sample_height_at_position(center)
	
	all_vertices.append(center_vertex)
	
	# Add outer ring vertices
	var outer_vertices = graph_config.calculate_vertex_positions(center, radius, vertex_count)
	all_vertices.append_array(outer_vertices)
	
	return all_vertices

func _calculate_edges() -> Array[GraphEdge]:
	"""Calculate edges: spokes (center to outer) + ring (outer to outer)"""
	var wheel_edges: Array[GraphEdge] = []
	
	if vertices.size() < 4:  # Need center + at least 3 outer vertices
		GameLogger.error("❌ WheelGraph: Need center + at least 3 outer vertices")
		return wheel_edges
	
	var center_index = 0  # First vertex is always center
	var outer_vertex_count = vertices.size() - 1  # Rest are outer vertices
	
	# Create spokes from center to each outer vertex
	for i in range(1, vertices.size()):  # Start from index 1 (skip center)
		var spoke_edge = GraphEdge.new(center_index, i, 1.0, "spoke")
		wheel_edges.append(spoke_edge)
	
	# Create ring edges connecting outer vertices in cycle
	for i in range(1, vertices.size()):  # Outer vertices start at index 1
		var current_index = i
		var next_index = (i % outer_vertex_count) + 1  # Wrap around, but skip center (index 0)
		var ring_edge = GraphEdge.new(current_index, next_index, 1.0, "ring")
		wheel_edges.append(ring_edge)
	
	return wheel_edges

func get_center_vertex() -> Vector3:
	"""Get the center hub vertex of the wheel"""
	return center_vertex if vertices.size() > 0 else Vector3.ZERO

func get_outer_vertices() -> Array[Vector3]:
	"""Get all outer ring vertices"""
	if vertices.size() <= 1:
		return []
	return vertices.slice(1)

func get_spoke_edges() -> Array[GraphEdge]:
	"""Get only the spoke edges (center to outer)"""
	var spokes: Array[GraphEdge] = []
	for edge in edges:
		if edge.edge_type == "spoke":
			spokes.append(edge)
	return spokes

func get_ring_edges() -> Array[GraphEdge]:
	"""Get only the ring edges (outer to outer)"""
	var rings: Array[GraphEdge] = []
	for edge in edges:
		if edge.edge_type == "ring":
			rings.append(edge)
	return rings

func _get_graph_description() -> String:
	"""Get description of this wheel graph"""
	var outer_count = vertices.size() - 1 if vertices.size() > 0 else 0
	return "W%d Wheel Graph (1 center + %d outer vertices, %d edges)" % [
		outer_count, outer_count, edges.size()
	]

func _validate_graph_properties() -> bool:
	"""Validate wheel graph structure"""
	if not super._validate_graph_properties():
		return false
	
	# Wheel-specific validation
	var outer_count = vertices.size() - 1
	var expected_edges = outer_count * 2  # spokes + ring edges
	
	if edges.size() != expected_edges:
		GameLogger.error("❌ WheelGraph: Expected %d edges, got %d" % [expected_edges, edges.size()])
		return false
	
	# Check we have the right number of spokes and ring edges
	var spoke_count = get_spoke_edges().size()
	var ring_count = get_ring_edges().size()
	
	if spoke_count != outer_count:
		GameLogger.error("❌ WheelGraph: Expected %d spokes, got %d" % [outer_count, spoke_count])
		return false
	
	if ring_count != outer_count:
		GameLogger.error("❌ WheelGraph: Expected %d ring edges, got %d" % [outer_count, ring_count])
		return false
	
	return true
