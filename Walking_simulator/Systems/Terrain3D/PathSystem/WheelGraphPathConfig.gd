extends Resource
class_name WheelGraphPathConfig

## Configuration resource for wheel graph path generation system
## Supports W4 (square), W5 (pentagon), W6 (hexagon), etc.

enum WheelType {
	W4 = 4,   # Square (persegi)
	W5 = 5,   # Pentagon 
	W6 = 6,   # Hexagon
	W7 = 7,   # Heptagon
	W8 = 8,   # Octagon
	W9 = 9    # Enneagon
}

enum SceneType {
	PAPUA,
	PASAR,
	TAMBORA,
	JAVA_BARAT
}

enum ObjectType {
	NPC,
	ARTIFACT,
	ITEM,
	MARKER,
	DECORATION
}

# === GRAPH STRUCTURE ===
@export_group("Graph Structure")
@export var wheel_type: WheelType = WheelType.W5
@export var hub_center: Vector3 = Vector3.ZERO
@export var outer_radius: float = 20.0
@export var inner_radius: float = 5.0  # For complex patterns with inner ring
@export var create_spokes: bool = true  # Lines from center to outer vertices
@export var create_outer_ring: bool = true  # Connect outer vertices in ring

# === PATH PROPERTIES ===
@export_group("Path Properties")
@export var path_width: float = 3.0
@export var path_height: float = 0.2
@export var path_material: Material
@export var collision_enabled: bool = true
@export var collision_layer: int = 1

# === VERTEX CONFIGURATION ===
@export_group("Vertex Objects")
@export var hub_vertex_config: VertexConfig
@export var outer_vertex_config: VertexConfig
@export var inner_vertex_config: VertexConfig  # For complex patterns
@export var spoke_midpoint_config: VertexConfig  # Objects along spokes

# === TERRAIN INTEGRATION ===
@export_group("Terrain Integration")
@export var follow_terrain_height: bool = true
@export var height_offset: float = 0.1
@export var terrain_conforming: bool = true
@export var smooth_height_transitions: bool = true
@export var terrain_sampling_precision: float = 1.0  # Sample every N meters

# === SCENE CONFIGURATION ===
@export_group("Scene Settings")
@export var scene_type: SceneType = SceneType.PAPUA
@export var cultural_theme: String = "Indonesian"
@export var randomize_rotation: bool = false
@export var rotation_offset: float = 0.0  # Base rotation in degrees

# === VISUAL SETTINGS ===
@export_group("Visual Settings")
@export var debug_mode: bool = false
@export var show_vertex_markers: bool = true
@export var marker_color: Color = Color.YELLOW
@export var path_color: Color = Color(0.6, 0.4, 0.2)  # Brown

func get_vertex_count() -> int:
	"""Get number of vertices for this wheel type"""
	return int(wheel_type)

func get_outer_vertex_positions() -> Array[Vector3]:
	"""Calculate positions of outer vertices"""
	var positions: Array[Vector3] = []
	var vertex_count = get_vertex_count()
	var angle_step = 2.0 * PI / vertex_count
	var base_rotation = deg_to_rad(rotation_offset)
	
	for i in range(vertex_count):
		var angle = i * angle_step + base_rotation
		var pos = Vector3(
			cos(angle) * outer_radius,
			0,
			sin(angle) * outer_radius
		) + hub_center
		positions.append(pos)
	
	return positions

func get_inner_vertex_positions() -> Array[Vector3]:
	"""Calculate positions of inner vertices (for complex patterns)"""
	var positions: Array[Vector3] = []
	if inner_radius <= 0:
		return positions
		
	var vertex_count = get_vertex_count()
	var angle_step = 2.0 * PI / vertex_count
	var base_rotation = deg_to_rad(rotation_offset)
	
	for i in range(vertex_count):
		var angle = i * angle_step + base_rotation + (angle_step / 2.0)  # Offset by half step
		var pos = Vector3(
			cos(angle) * inner_radius,
			0,
			sin(angle) * inner_radius
		) + hub_center
		positions.append(pos)
	
	return positions

func validate_configuration() -> bool:
	"""Validate the configuration settings"""
	if outer_radius <= 0:
		push_error("WheelGraphPathConfig: outer_radius must be positive")
		return false
	
	if path_width <= 0:
		push_error("WheelGraphPathConfig: path_width must be positive")
		return false
	
	if int(wheel_type) < 3:
		push_error("WheelGraphPathConfig: wheel_type must be at least 3 vertices")
		return false
	
	return true

func get_configuration_summary() -> String:
	"""Get a summary of the configuration for debugging"""
	return "WheelGraphPath: %s vertices, radius %.1fm, %s scene" % [
		WheelType.keys()[wheel_type - 4],  # Adjust for enum offset
		outer_radius,
		SceneType.keys()[scene_type]
	]
