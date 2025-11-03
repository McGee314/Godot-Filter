extends BaseGraphConfig
class_name CycleGraphConfig

## Configuration for Cycle Graphs (simple ring connections)
## Examples: Triangle (C3), Square (C4), Pentagon (C5), Hexagon (C6)

enum CycleType {
	C3 = 3,   # Triangle
	C4 = 4,   # Square (Diamond)
	C5 = 5,   # Pentagon
	C6 = 6,   # Hexagon
	C7 = 7,   # Heptagon
	C8 = 8,   # Octagon
	C9 = 9    # Enneagon
}

# === CYCLE SPECIFIC ===
@export_group("Cycle Properties")
@export var cycle_type: CycleType = CycleType.C4
@export var create_inner_paths: bool = false  # Create paths inside the cycle
@export var inner_radius: float = 10.0

# Override base class vertex count based on cycle type
func _ready():
	vertex_count = cycle_type

func calculate_vertex_positions(center: Vector3, r: float, _count: int, rotation_offset: float = 0.0) -> Array[Vector3]:
	"""Calculate vertex positions for cycle graph"""
	var positions: Array[Vector3] = []
	var actual_count = cycle_type  # Use cycle type instead of _count parameter
	
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
	"""Get summary of cycle graph configuration"""
	return "%s (C%d) - %d vertices, radius: %.1fm" % [
		CycleType.keys()[cycle_type].replace("C", "Cycle-"),
		cycle_type,
		cycle_type,
		radius
	]

func get_graph_name() -> String:
	"""Get human-readable name for this cycle graph"""
	match cycle_type:
		CycleType.C3:
			return "Triangle Cycle"
		CycleType.C4:
			return "Square Cycle (Diamond)"
		CycleType.C5:
			return "Pentagon Cycle"
		CycleType.C6:
			return "Hexagon Cycle"
		CycleType.C7:
			return "Heptagon Cycle"
		CycleType.C8:
			return "Octagon Cycle"
		CycleType.C9:
			return "Enneagon Cycle"
		_:
			return "Custom Cycle"

func validate_configuration() -> bool:
	"""Validate cycle graph configuration"""
	if not super.validate_configuration():
		return false
	
	if cycle_type < CycleType.C3:
		GameLogger.error("❌ CycleGraphConfig: Cycle type must be at least C3 (triangle)")
		return false
	
	if radius <= 0:
		GameLogger.error("❌ CycleGraphConfig: Radius must be positive")
		return false
	
	return true
