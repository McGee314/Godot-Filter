extends Resource
class_name BaseGraphConfig

## Base configuration class for all graph types
## Provides common properties and validation

enum ObjectType {
	NPC,
	ARTIFACT,
	ITEM,
	MARKER,
	DECORATION
}

enum SceneType {
	PAPUA,
	PASAR,
	TAMBORA,
	JAVA_BARAT
}

# === GRAPH STRUCTURE ===
@export_group("Graph Structure")
@export var center_position: Vector3 = Vector3.ZERO
@export var radius: float = 25.0
@export var vertex_count: int = 5

# === VISUAL PROPERTIES ===
@export_group("Visual Properties")
@export var path_width: float = 3.0
@export var path_height: float = 0.2
@export var path_material: Material
@export var path_color: Color = Color(0.6, 0.4, 0.2)

# === TERRAIN INTEGRATION ===
@export_group("Terrain Integration")
@export var follow_terrain_height: bool = true
@export var height_offset: float = 0.1
@export var terrain_conforming: bool = true

# === COLLISION ===
@export_group("Collision")
@export var collision_enabled: bool = true
@export var collision_layer: int = 1

# === VERTEX CONFIGURATION ===
@export_group("Vertex Objects")
@export var vertex_config: GraphVertexConfig

# === SCENE SETTINGS ===
@export_group("Scene Settings")
@export var scene_type: SceneType = SceneType.PAPUA
@export var cultural_theme: String = "Indonesian"

# === DEBUG ===
@export_group("Debug")
@export var debug_mode: bool = false
@export var show_vertex_markers: bool = true
@export var marker_color: Color = Color.YELLOW

func validate_configuration() -> bool:
	"""Validate the configuration settings"""
	if radius <= 0:
		push_error("BaseGraphConfig: radius must be positive")
		return false
	
	if vertex_count < 3:
		push_error("BaseGraphConfig: vertex_count must be at least 3")
		return false
	
	if path_width <= 0:
		push_error("BaseGraphConfig: path_width must be positive")
		return false
	
	return true

func get_configuration_id() -> String:
	"""Get a unique identifier for this configuration"""
	return "%s_%dv_%.0fr" % [
		SceneType.keys()[scene_type],
		vertex_count,
		radius
	]

func get_configuration_summary() -> String:
	"""Get a summary of the configuration for debugging"""
	return "Graph: %d vertices, radius %.1fm, %s scene" % [
		vertex_count,
		radius,
		SceneType.keys()[scene_type]
	]

func calculate_vertex_positions(center: Vector3, r: float, count: int, rotation_offset: float = 0.0) -> Array[Vector3]:
	"""Calculate positions for vertices arranged in a circle"""
	var positions: Array[Vector3] = []
	var angle_step = 2.0 * PI / count
	var base_rotation = deg_to_rad(rotation_offset)
	
	for i in range(count):
		var angle = i * angle_step + base_rotation
		var pos = Vector3(
			cos(angle) * r,
			0,
			sin(angle) * r
		) + center
		positions.append(pos)
	
	return positions

