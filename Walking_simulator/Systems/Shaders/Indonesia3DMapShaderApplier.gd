class_name Indonesia3DMapShaderApplier
extends Node

## Specialized shader application for Indonesia 3D Map
## Follows Single Responsibility Principle - only handles shader application for map scenes

@export var shader_manager: ShaderManager
@export var auto_apply_on_ready: bool = true

# Shader configurations for different map elements
const OCEAN_SHADER_CONFIG = {
	"wave_speed": 0.8,
	"wave_height": 0.2,
	"wave_frequency": 1.2,
	"shallow_color": Color(0.4, 0.8, 1.0, 0.8),
	"deep_color": Color(0.0, 0.2, 0.6, 1.0),
	"foam_threshold": 0.6,
	"foam_intensity": 1.2
}

const ISLAND_SHADER_CONFIG = {
	"height_scale": 3.0,
	"sand_level": 0.1,
	"grass_level": 0.3,
	"rock_level": 0.7,
	"slope_threshold": 0.6,
	"sand_scale": 8.0,
	"grass_scale": 12.0,
	"rock_scale": 4.0
}

const PLACEHOLDER_GLOW_CONFIG = {
	"glow_intensity": 1.0,
	"pulse_speed": 2.0,
	"enable_pulse": true,
	"rim_power": 2.5
}

func _ready():
	if not shader_manager:
		# Try to find existing ShaderManager
		shader_manager = get_node_or_null("/root/ShaderManager") as ShaderManager
		if not shader_manager:
			GameLogger.warning("⚠️ ShaderManager not found, creating local instance")
			shader_manager = ShaderManager.new()
			shader_manager.name = "ShaderManager"
			add_child(shader_manager)
	
	if auto_apply_on_ready:
		call_deferred("apply_all_shaders")

## Apply shaders to all map elements
func apply_all_shaders():
	GameLogger.info("🎨 Applying shaders to Indonesia 3D Map...")
	
	apply_ocean_shader()
	apply_island_shader()
	apply_placeholder_shaders()
	
	GameLogger.info("✅ All map shaders applied successfully")

## Apply animated wave shader to ocean/sea plane
func apply_ocean_shader():
	var sea_plane = get_ocean_node()
	if not sea_plane:
		GameLogger.warning("⚠️ Sea plane not found for ocean shader")
		return
	
	var success = shader_manager.apply_shader_to_object(
		sea_plane, 
		"ocean_waves", 
		OCEAN_SHADER_CONFIG
	)
	
	if success:
		GameLogger.info("🌊 Ocean wave shader applied successfully")
	else:
		GameLogger.error("❌ Failed to apply ocean shader")

## Apply terrain blending shader to island
func apply_island_shader():
	var island_mesh = get_island_node()
	if not island_mesh:
		GameLogger.warning("⚠️ Island mesh not found for terrain shader")
		return
	
	# For now, use enhanced standard material until we have terrain textures
	apply_enhanced_island_material(island_mesh)

## Apply enhanced standard material to island (fallback)
func apply_enhanced_island_material(island_mesh: MeshInstance3D):
	var enhanced_material = StandardMaterial3D.new()
	
	# Load texture if available
	var texture_path = "res://Assets/Students/indonesiamap/texture/pulau_indonesia_Mixed_AO.png"
	if ResourceLoader.exists(texture_path):
		enhanced_material.albedo_texture = load(texture_path)
	
	# Enhanced material properties
	enhanced_material.albedo_color = Color(1.0, 0.95, 0.85)  # Warm tone
	enhanced_material.roughness = 0.6
	enhanced_material.metallic = 0.0
	# Note: specular property removed in Godot 4, using roughness instead
	
	# Subtle emission for warmth
	enhanced_material.emission_enabled = true
	enhanced_material.emission = Color(0.1, 0.08, 0.05)
	enhanced_material.emission_energy = 0.2
	
	island_mesh.material_override = enhanced_material
	GameLogger.info("🏝️ Enhanced island material applied")

## Apply interactive glow shaders to placeholders
func apply_placeholder_shaders():
	var placeholders = get_placeholder_nodes()
	
	for placeholder in placeholders:
		var region_color = get_placeholder_region_color(placeholder)
		var glow_config = PLACEHOLDER_GLOW_CONFIG.duplicate()
		glow_config["glow_color"] = region_color
		glow_config["base_color"] = region_color
		
		var success = shader_manager.apply_shader_to_object(
			placeholder,
			"interactive_glow",
			glow_config
		)
		
		if success:
			GameLogger.info("✨ Glow shader applied to: " + placeholder.name)

## Update placeholder interaction state
func update_placeholder_interaction(placeholder: Node3D, _is_hovered: bool = false, _is_selected: bool = false):
	if not placeholder or not shader_manager:
		return
	
	shader_manager.update_shader_parameters(placeholder, {
		"is_hovered": _is_hovered,
		"is_selected": _is_selected
	})
	
	GameLogger.info("🎯 Updated interaction state for: " + placeholder.name)

## Animate ocean waves (can be called from external scripts)
func animate_ocean_waves(speed_multiplier: float = 1.0):
	var sea_plane = get_ocean_node()
	if not sea_plane:
		return
	
	var new_speed = OCEAN_SHADER_CONFIG["wave_speed"] * speed_multiplier
	shader_manager.update_shader_parameters(sea_plane, {"wave_speed": new_speed})

## Get ocean/sea plane node
func get_ocean_node() -> Node3D:
	# Try multiple possible paths
	var possible_paths = [
		"SeaPlane",
		"../SeaPlane", 
		"../../SeaPlane",
		"Ocean",
		"Water"
	]
	
	for path in possible_paths:
		var node = get_node_or_null(path)
		if node and node is Node3D:
			return node as Node3D
	
	# Search recursively
	return find_node_by_name(get_tree().current_scene, "SeaPlane") as Node3D

## Get island mesh node
func get_island_node() -> MeshInstance3D:
	var possible_paths = [
		"IndonesiaMap",
		"../IndonesiaMap",
		"../../IndonesiaMap",
		"Island",
		"Map"
	]
	
	for path in possible_paths:
		var node = get_node_or_null(path)
		if node and node is MeshInstance3D:
			return node as MeshInstance3D
	
	return find_node_by_name(get_tree().current_scene, "IndonesiaMap") as MeshInstance3D

## Get all placeholder nodes
func get_placeholder_nodes() -> Array[Node3D]:
	var placeholders: Array[Node3D] = []
	var scene_root = get_tree().current_scene
	
	# Recursively find all nodes with "Placeholder_" in name
	_find_placeholder_nodes_recursive(scene_root, placeholders)
	
	return placeholders

## Recursive helper to find placeholder nodes
func _find_placeholder_nodes_recursive(node: Node, placeholders: Array[Node3D]):
	if node.name.begins_with("Placeholder_") and node is Node3D:
		placeholders.append(node as Node3D)
	
	for child in node.get_children():
		_find_placeholder_nodes_recursive(child, placeholders)

## Get region color for placeholder
func get_placeholder_region_color(placeholder: Node3D) -> Color:
	var region_id = placeholder.name.replace("Placeholder_", "")
	
	# Default colors for regions
	match region_id:
		"indonesia_barat":
			return Color.RED
		"indonesia_tengah":
			return Color.GREEN
		"indonesia_timur":
			return Color.BLUE
		_:
			return Color.WHITE

## Utility function to find node by name recursively
func find_node_by_name(root: Node, target_name: String) -> Node:
	if root.name == target_name:
		return root
	
	for child in root.get_children():
		var result = find_node_by_name(child, target_name)
		if result:
			return result
	
	return null

## Public API for external shader control
func set_ocean_wave_intensity(intensity: float):
	var sea_plane = get_ocean_node()
	if sea_plane:
		shader_manager.update_shader_parameters(sea_plane, {"wave_height": intensity})

func set_placeholder_glow_intensity(placeholder: Node3D, intensity: float):
	if placeholder:
		shader_manager.update_shader_parameters(placeholder, {"glow_intensity": intensity})

func enable_placeholder_pulse(placeholder: Node3D, enable: bool):
	if placeholder:
		shader_manager.update_shader_parameters(placeholder, {"enable_pulse": enable})
