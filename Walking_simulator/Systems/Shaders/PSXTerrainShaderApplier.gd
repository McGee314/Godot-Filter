class_name PSXTerrainShaderApplier
extends Node

## Specialized shader applier for PSX-style terrain texturing on Indonesia map
## Uses the comprehensive PSX texture collection for realistic height-based terrain

@export var shader_manager: ShaderManager
@export var enable_psx_style: bool = true
@export var auto_apply_on_ready: bool = true

# PSX texture paths - carefully selected for Indonesian terrain
const PSX_TEXTURE_PATHS = {
	# Beach/coastal areas (sand-like)
	"sand_color": "res://Assets/PSX/PSX Textures/Color/dirt_2.png",  # Light sandy dirt
	"sand_normal": "res://Assets/PSX/PSX Textures/Normal/dirt_2.png",
	
	# Grass areas (tropical vegetation)
	"grass_color": "res://Assets/PSX/PSX Textures/Color/grass_3.png",  # Lush tropical grass
	"grass_normal": "res://Assets/PSX/PSX Textures/Normal/grass_3.png",
	
	# Dirt areas (inland soil)
	"dirt_color": "res://Assets/PSX/PSX Textures/Color/dirt_5.png",  # Rich brown soil
	"dirt_normal": "res://Assets/PSX/PSX Textures/Normal/dirt_5.png",
	
	# Rock areas (mountains, cliffs)
	"rock_color": "res://Assets/PSX/PSX Textures/Color/rock_2.png",  # Natural rock
	"rock_normal": "res://Assets/PSX/PSX Textures/Normal/rock_2.png",
	
	# Snow areas (high peaks)
	"snow_color": "res://Assets/PSX/PSX Textures/Color/snow_1.png",  # Clean snow
	"snow_normal": "res://Assets/PSX/PSX Textures/Normal/snow_1.png"
}

# Terrain configuration for Indonesian geography
const INDONESIA_TERRAIN_CONFIG = {
	"height_scale": 15.0,      # Scale for height-based blending
	"sand_level": 0.05,        # Beach areas (very low)
	"grass_level": 0.2,        # Tropical plains
	"dirt_level": 0.4,         # Inland areas
	"rock_level": 0.7,         # Mountain slopes
	"snow_level": 0.9,         # High peaks (rare in Indonesia)
	"slope_threshold": 0.5,    # When slopes become rocky
	"slope_blend": 0.2,        # Slope blending smoothness
	"sand_scale": 12.0,        # Texture repetition
	"grass_scale": 8.0,
	"dirt_scale": 6.0,
	"rock_scale": 4.0,
	"snow_scale": 3.0,
	"color_quantization": 32.0, # PSX-style color reduction
	"dither_strength": 0.2,     # PSX dithering effect
	"enable_psx_style": true    # Enable retro PSX look
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
		call_deferred("apply_psx_terrain_shader")

## Apply PSX terrain shader to Indonesia map
func apply_psx_terrain_shader():
	GameLogger.info("🎨 Applying PSX terrain shader to Indonesia map...")
	
	var island_mesh = get_indonesia_map_node()
	if not island_mesh:
		GameLogger.warning("⚠️ Indonesia map node not found")
		return
	
	# Load all PSX textures
	var textures = _load_psx_textures()
	if textures.is_empty():
		GameLogger.warning("⚠️ Failed to load PSX textures, using fallback")
		_apply_fallback_terrain_material(island_mesh)
		return
	
	# Create terrain material with PSX textures
	var terrain_config = INDONESIA_TERRAIN_CONFIG.duplicate()
	terrain_config.merge(textures)
	
	var success = shader_manager.apply_shader_to_object(
		island_mesh,
		"psx_terrain_height",
		terrain_config
	)
	
	if success:
		GameLogger.info("✅ PSX terrain shader applied successfully")
	else:
		GameLogger.error("❌ Failed to apply PSX terrain shader")
		_apply_fallback_terrain_material(island_mesh)

## Load all PSX textures for terrain
func _load_psx_textures() -> Dictionary:
	var textures = {}
	var load_count = 0
	var total_count = PSX_TEXTURE_PATHS.size()
	
	for texture_name in PSX_TEXTURE_PATHS:
		var texture_path = PSX_TEXTURE_PATHS[texture_name]
		
		if ResourceLoader.exists(texture_path):
			var texture = load(texture_path)
			if texture:
				textures[texture_name] = texture
				load_count += 1
				GameLogger.info("📸 Loaded PSX texture: " + texture_name)
			else:
				GameLogger.warning("⚠️ Failed to load texture: " + texture_path)
		else:
			GameLogger.warning("⚠️ PSX texture not found: " + texture_path)
	
	GameLogger.info("📦 Loaded " + str(load_count) + "/" + str(total_count) + " PSX textures")
	return textures

## Apply fallback material if PSX shaders fail
func _apply_fallback_terrain_material(island_mesh: MeshInstance3D):
	GameLogger.info("🔄 Applying fallback terrain material...")
	
	var fallback_material = StandardMaterial3D.new()
	
	# Try to load the original Indonesia texture
	var texture_path = "res://Assets/Students/indonesiamap/texture/pulau_indonesia_Mixed_AO.png"
	if ResourceLoader.exists(texture_path):
		fallback_material.albedo_texture = load(texture_path)
	
	# Enhanced material properties for better appearance
	fallback_material.albedo_color = Color(0.9, 0.85, 0.7)  # Warm island tone
	fallback_material.roughness = 0.7
	fallback_material.metallic = 0.0
	
	# Add subtle emission for warmth
	fallback_material.emission_enabled = true
	fallback_material.emission = Color(0.05, 0.04, 0.02)
	fallback_material.emission_energy = 0.15
	
	island_mesh.material_override = fallback_material
	GameLogger.info("✅ Fallback terrain material applied")

## Get Indonesia map node
func get_indonesia_map_node() -> MeshInstance3D:
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
	
	# Search recursively in scene
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

## Update terrain parameters dynamically
func update_terrain_settings(new_settings: Dictionary):
	var island_mesh = get_indonesia_map_node()
	if not island_mesh or not shader_manager:
		return
	
	shader_manager.update_shader_parameters(island_mesh, new_settings)
	GameLogger.info("🔧 Updated terrain settings: " + str(new_settings.keys()))

## Enable/disable PSX style effects
func set_psx_style_enabled(enabled: bool):
	update_terrain_settings({"enable_psx_style": enabled})

## Adjust height-based blending levels
func set_terrain_levels(sand: float, grass: float, dirt: float, rock: float, snow: float):
	update_terrain_settings({
		"sand_level": sand,
		"grass_level": grass, 
		"dirt_level": dirt,
		"rock_level": rock,
		"snow_level": snow
	})

## Get available PSX textures for UI selection
func get_available_textures() -> Dictionary:
	return PSX_TEXTURE_PATHS

## Switch to different PSX texture set
func switch_texture_set(texture_type: String, new_texture_name: String):
	var new_path = "res://Assets/PSX/PSX Textures/Color/" + new_texture_name + ".png"
	var normal_path = "res://Assets/PSX/PSX Textures/Normal/" + new_texture_name + ".png"
	
	if ResourceLoader.exists(new_path):
		var new_texture = load(new_path)
		var normal_texture = load(normal_path) if ResourceLoader.exists(normal_path) else null
		
		var params = {}
		params[texture_type + "_texture"] = new_texture
		if normal_texture:
			params[texture_type + "_normal"] = normal_texture
		
		update_terrain_settings(params)
		GameLogger.info("🔄 Switched " + texture_type + " texture to: " + new_texture_name)
	else:
		GameLogger.warning("⚠️ Texture not found: " + new_path)
