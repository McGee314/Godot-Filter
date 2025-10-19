class_name SimpleTerrainApplier
extends Node

## Simple terrain shader applier using basic PSX textures
## Focuses on getting working terrain textures first, then complexity later

@export var shader_manager: ShaderManager
@export var auto_apply_on_ready: bool = true

# Simple PSX texture selection (known working textures)
const SIMPLE_TERRAIN_CONFIG = {
	"grass_texture": "res://Assets/PSX/PSX Textures/Color/grass_3.png",
	"rock_texture": "res://Assets/PSX/PSX Textures/Color/rock_2.png", 
	"dirt_texture": "res://Assets/PSX/PSX Textures/Color/dirt_5.png",
	"height_scale": 8.0,
	"grass_level": 0.3,
	"rock_level": 0.7,
	"texture_scale": 6.0
}

func _ready():
	if not shader_manager:
		shader_manager = get_node_or_null("/root/ShaderManager") as ShaderManager
		if not shader_manager:
			GameLogger.warning("⚠️ ShaderManager not found, creating local instance")
			shader_manager = ShaderManager.new()
			shader_manager.name = "ShaderManager"
			add_child(shader_manager)
	
	if auto_apply_on_ready:
		call_deferred("apply_simple_terrain_shader")

## Apply simple terrain shader to Indonesia map
func apply_simple_terrain_shader():
	GameLogger.info("🎨 Applying simple terrain shader to Indonesia map...")
	
	var island_mesh = get_indonesia_map_node()
	if not island_mesh:
		GameLogger.warning("⚠️ Indonesia map node not found")
		return
	
	# Load PSX textures
	var config = _load_simple_textures()
	if config.is_empty():
		GameLogger.warning("⚠️ Failed to load PSX textures, using enhanced standard material")
		_apply_enhanced_standard_material(island_mesh)
		return
	
	# Apply simple terrain shader
	var success = shader_manager.apply_shader_to_object(
		island_mesh,
		"simple_terrain",
		config
	)
	
	if success:
		GameLogger.info("✅ Simple terrain shader applied successfully")
	else:
		GameLogger.error("❌ Failed to apply terrain shader, using fallback")
		_apply_enhanced_standard_material(island_mesh)

## Load PSX textures for simple terrain
func _load_simple_textures() -> Dictionary:
	var config = SIMPLE_TERRAIN_CONFIG.duplicate()
	var loaded_textures = {}
	
	# Load each texture
	for texture_key in ["grass_texture", "rock_texture", "dirt_texture"]:
		var texture_path = config[texture_key]
		
		if ResourceLoader.exists(texture_path):
			var texture = load(texture_path)
			if texture:
				loaded_textures[texture_key] = texture
				GameLogger.info("📸 Loaded PSX texture: " + texture_key + " from " + texture_path)
			else:
				GameLogger.warning("⚠️ Failed to load texture: " + texture_path)
				return {}
		else:
			GameLogger.warning("⚠️ PSX texture not found: " + texture_path)
			return {}
	
	# Combine settings with loaded textures
	config.merge(loaded_textures)
	GameLogger.info("📦 All PSX textures loaded successfully")
	return config

## Enhanced standard material fallback
func _apply_enhanced_standard_material(island_mesh: MeshInstance3D):
	GameLogger.info("🔄 Applying enhanced standard material...")
	
	var material = StandardMaterial3D.new()
	
	# Try to load original Indonesia texture
	var texture_path = "res://Assets/Students/indonesiamap/texture/pulau_indonesia_Mixed_AO.png"
	if ResourceLoader.exists(texture_path):
		material.albedo_texture = load(texture_path)
		GameLogger.info("📸 Using original Indonesia texture")
	
	# Enhanced properties for better visibility and artistic appeal
	material.albedo_color = Color(1.2, 1.1, 0.9)  # Brighter, more saturated island color
	material.roughness = 0.6
	material.metallic = 0.0
	
	# Stronger emission for better visibility at distance
	material.emission_enabled = true
	material.emission = Color(0.15, 0.12, 0.08)  # Warmer, stronger glow
	material.emission_energy = 0.3
	
	island_mesh.material_override = material
	GameLogger.info("✅ Enhanced standard material applied")

## Get Indonesia map node
func get_indonesia_map_node() -> MeshInstance3D:
	var possible_paths = [
		"IndonesiaMap",
		"../IndonesiaMap", 
		"../../IndonesiaMap"
	]
	
	for path in possible_paths:
		var node = get_node_or_null(path)
		if node and node is MeshInstance3D:
			return node as MeshInstance3D
	
	# Search recursively
	return _find_node_by_name(get_tree().current_scene, "IndonesiaMap") as MeshInstance3D

## Utility function to find node by name recursively
func _find_node_by_name(root: Node, target_name: String) -> Node:
	if root.name == target_name:
		return root
	
	for child in root.get_children():
		var result = _find_node_by_name(child, target_name)
		if result:
			return result
	
	return null

## Public API for terrain customization
func update_terrain_levels(grass_level: float, rock_level: float):
	var island_mesh = get_indonesia_map_node()
	if island_mesh and shader_manager:
		shader_manager.update_shader_parameters(island_mesh, {
			"grass_level": grass_level,
			"rock_level": rock_level
		})

func update_texture_scale(scale: float):
	var island_mesh = get_indonesia_map_node()
	if island_mesh and shader_manager:
		shader_manager.update_shader_parameters(island_mesh, {
			"texture_scale": scale
		})
