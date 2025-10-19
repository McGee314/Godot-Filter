extends BaseGraphConfig
class_name WheelGraphConfig

## Configuration for Wheel Graphs (cycle + center hub with spokes)
## Examples: W3, W4 (square), W5 (pentagon), W6 (hexagon), W7, W8, W9

enum WheelType {
	W3 = 3,   # Wheel Triangle
	W4 = 4,   # Wheel Square
	W5 = 5,   # Wheel Pentagon
	W6 = 6,   # Wheel Hexagon
	W7 = 7,   # Wheel Heptagon
	W8 = 8,   # Wheel Octagon
	W9 = 9    # Wheel Enneagon
}

# === WHEEL SPECIFIC ===
@export_group("Wheel Properties")
@export var wheel_type: WheelType = WheelType.W5
@export var create_spokes: bool = true  # Lines from center to outer vertices
@export var create_outer_ring: bool = true  # Connect outer vertices in cycle
@export var inner_radius: float = 5.0  # For complex patterns with inner ring

# === HUB CONFIGURATION ===
@export_group("Hub Configuration")
@export var hub_vertex_config: GraphVertexConfig
@export var hub_scale: float = 1.5
@export var hub_special_objects: bool = true

# Override base class vertex count based on wheel type
func _ready():
	vertex_count = wheel_type

func calculate_vertex_positions(center: Vector3, r: float, _count: int, rotation_offset: float = 0.0) -> Array[Vector3]:
	"""Calculate vertex positions for wheel graph (outer ring only - center handled separately)"""
	var positions: Array[Vector3] = []
	var actual_count = wheel_type  # Use wheel type instead of _count parameter
	
	for i in range(actual_count):
		var angle = i * (2.0 * PI / actual_count) + (rotation_offset * PI / 180.0)
		var x = center.x + cos(angle) * r
		var z = center.z + sin(angle) * r
		var y = center.y
		
		# Apply terrain height if enabled
		if follow_terrain_height:
			# Height will be sampled by terrain sampler during generation
			pass
		
		positions.append(Vector3(x, y, z))
	
	return positions

func get_configuration_summary() -> String:
	"""Get summary of wheel graph configuration"""
	return "%s (W%d) - 1 center + %d outer vertices, radius: %.1fm" % [
		WheelType.keys()[wheel_type].replace("W", "Wheel-"),
		wheel_type,
		wheel_type,
		radius
	]

func get_graph_name() -> String:
	"""Get human-readable name for this wheel graph"""
	match wheel_type:
		WheelType.W3:
			return "Wheel Triangle"
		WheelType.W4:
			return "Wheel Square"
		WheelType.W5:
			return "Wheel Pentagon"
		WheelType.W6:
			return "Wheel Hexagon"
		WheelType.W7:
			return "Wheel Heptagon"
		WheelType.W8:
			return "Wheel Octagon"
		WheelType.W9:
			return "Wheel Enneagon"
		_:
			return "Custom Wheel"

func validate_configuration() -> bool:
	"""Validate wheel graph configuration"""
	if not super.validate_configuration():
		return false
	
	if wheel_type < WheelType.W3:
		GameLogger.error("❌ WheelGraphConfig: Wheel type must be at least W3")
		return false
	
	if radius <= 0:
		GameLogger.error("❌ WheelGraphConfig: Radius must be positive")
		return false
	
	if inner_radius >= radius:
		GameLogger.error("❌ WheelGraphConfig: Inner radius must be less than outer radius")
		return false
	
	return true

func get_total_vertex_count() -> int:
	"""Get total vertex count including center hub"""
	return wheel_type + 1  # outer vertices + center

func get_total_edge_count() -> int:
	"""Get total edge count (spokes + ring edges)"""
	var spoke_count = wheel_type if create_spokes else 0
	var ring_count = wheel_type if create_outer_ring else 0
	return spoke_count + ring_count
