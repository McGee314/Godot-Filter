extends RefCounted
class_name Edge

## Represents an edge connection between two vertices in a graph
## Used by all graph types for path generation

var start_vertex: Vector3
var end_vertex: Vector3
var edge_type: EdgeType
var metadata: Dictionary = {}

enum EdgeType {
	SPOKE,     # From center to outer vertex (wheel graphs)
	RING,      # Between adjacent outer vertices (cycle/wheel)
	CHORD,     # Between non-adjacent vertices (complete graphs)
	BRANCH     # Tree/path graph connections
}

func _init(start: Vector3, end: Vector3, type: EdgeType = EdgeType.RING, meta: Dictionary = {}):
	"""Initialize edge with start and end vertices"""
	start_vertex = start
	end_vertex = end
	edge_type = type
	metadata = meta

func get_length() -> float:
	"""Get the length of this edge"""
	return start_vertex.distance_to(end_vertex)

func get_midpoint() -> Vector3:
	"""Get the midpoint of this edge"""
	return (start_vertex + end_vertex) / 2.0

func get_direction() -> Vector3:
	"""Get normalized direction vector from start to end"""
	return (end_vertex - start_vertex).normalized()

func is_spoke() -> bool:
	"""Check if this edge is a spoke (center to outer vertex)"""
	return edge_type == EdgeType.SPOKE

func is_ring() -> bool:
	"""Check if this edge is part of the outer ring"""
	return edge_type == EdgeType.RING

func get_edge_info() -> String:
	"""Get debug information about this edge"""
	return "Edge[%s]: %.1f units from %s to %s" % [
		EdgeType.keys()[edge_type],
		get_length(),
		start_vertex,
		end_vertex
	]
