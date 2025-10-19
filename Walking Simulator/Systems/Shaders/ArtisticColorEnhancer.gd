class_name ArtisticColorEnhancer
extends Node

## Artistic color enhancement system for better visual appeal and visibility
## Provides various color schemes and enhancement techniques

# Artistic color palettes for Indonesian geography
const ARTISTIC_PALETTES = {
	"tropical_vibrant": {
		"name": "Tropical Vibrant",
		"description": "Bright, saturated colors for tropical islands",
		"island_base": Color(1.3, 1.2, 0.95),
		"island_emission": Color(0.2, 0.15, 0.1),
		"emission_energy": 0.4,
		"sea_shallow": Color(0.3, 0.7, 1.0, 0.8),
		"sea_deep": Color(0.0, 0.3, 0.8, 1.0)
	},
	"sunset_golden": {
		"name": "Sunset Golden",
		"description": "Warm golden hour lighting",
		"island_base": Color(1.4, 1.1, 0.8),
		"island_emission": Color(0.3, 0.2, 0.1),
		"emission_energy": 0.5,
		"sea_shallow": Color(0.4, 0.6, 0.9, 0.8),
		"sea_deep": Color(0.1, 0.2, 0.6, 1.0)
	},
	"emerald_paradise": {
		"name": "Emerald Paradise", 
		"description": "Rich emerald and jade tones",
		"island_base": Color(1.1, 1.3, 1.0),
		"island_emission": Color(0.1, 0.25, 0.15),
		"emission_energy": 0.3,
		"sea_shallow": Color(0.2, 0.8, 0.7, 0.8),
		"sea_deep": Color(0.0, 0.4, 0.5, 1.0)
	},
	"volcanic_dramatic": {
		"name": "Volcanic Dramatic",
		"description": "Dramatic contrasts for volcanic islands",
		"island_base": Color(1.2, 1.0, 0.8),
		"island_emission": Color(0.25, 0.15, 0.05),
		"emission_energy": 0.6,
		"sea_shallow": Color(0.2, 0.5, 0.9, 0.8),
		"sea_deep": Color(0.0, 0.1, 0.5, 1.0)
	}
}

@export var current_palette: String = "tropical_vibrant"
@export var auto_apply_on_ready: bool = true

var enhanced_materials: Dictionary = {}

func _ready():
	if auto_apply_on_ready:
		call_deferred("apply_artistic_enhancement")

## Apply artistic color enhancement to scene
func apply_artistic_enhancement():
	GameLogger.info("🎨 Applying artistic color enhancement: " + current_palette)
	
	var palette = ARTISTIC_PALETTES.get(current_palette, ARTISTIC_PALETTES["tropical_vibrant"])
	
	enhance_island_colors(palette)
	enhance_sea_colors(palette)
	enhance_lighting(palette)
	
	GameLogger.info("✅ Artistic enhancement applied successfully")

## Enhance island colors for better visibility
func enhance_island_colors(palette: Dictionary):
	var island_mesh = get_indonesia_map_node()
	if not island_mesh:
		return
	
	# Create vibrant island material
	var enhanced_material = StandardMaterial3D.new()
	
	# Load original texture if available
	var texture_path = "res://Assets/Students/indonesiamap/texture/pulau_indonesia_Mixed_AO.png"
	if ResourceLoader.exists(texture_path):
		enhanced_material.albedo_texture = load(texture_path)
	
	# Apply artistic color palette
	enhanced_material.albedo_color = palette["island_base"]
	enhanced_material.roughness = 0.5  # Less rough for more vibrant appearance
	enhanced_material.metallic = 0.0
	
	# Strong emission for visibility at distance
	enhanced_material.emission_enabled = true
	enhanced_material.emission = palette["island_emission"]
	enhanced_material.emission_energy = palette["emission_energy"]
	
	# Add subtle rim lighting effect
	enhanced_material.rim_enabled = true
	enhanced_material.rim = 0.3
	enhanced_material.rim_tint = 0.5
	
	island_mesh.material_override = enhanced_material
	enhanced_materials["island"] = enhanced_material
	
	GameLogger.info("🏝️ Enhanced island colors applied")

## Enhance sea colors for better contrast
func enhance_sea_colors(palette: Dictionary):
	var sea_plane = get_sea_plane_node()
	if not sea_plane:
		return
	
	# Create vibrant sea material
	var sea_material = StandardMaterial3D.new()
	sea_material.albedo_color = palette["sea_shallow"]
	sea_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sea_material.roughness = 0.0  # Smooth water surface
	sea_material.metallic = 0.2   # Slight metallic for reflections
	
	# Add subtle emission for depth
	sea_material.emission_enabled = true
	sea_material.emission = palette["sea_deep"] * 0.1
	sea_material.emission_energy = 0.2
	
	sea_plane.material_override = sea_material
	enhanced_materials["sea"] = sea_material
	
	GameLogger.info("🌊 Enhanced sea colors applied")

## Enhance lighting for better visibility
func enhance_lighting(palette: Dictionary):
	var sun_light = get_sun_light_node()
	if sun_light:
		# Adjust sun light for better island visibility
		sun_light.light_energy = 1.4  # Brighter light
		sun_light.light_color = Color(1.0, 0.95, 0.85)  # Warm sunlight
		GameLogger.info("☀️ Enhanced sun lighting")

## Switch to different artistic palette
func switch_palette(palette_name: String):
	if palette_name not in ARTISTIC_PALETTES:
		GameLogger.warning("⚠️ Unknown palette: " + palette_name)
		return
	
	current_palette = palette_name
	apply_artistic_enhancement()
	GameLogger.info("🎨 Switched to palette: " + palette_name)

## Get available palettes for UI
func get_available_palettes() -> Array[String]:
	return ARTISTIC_PALETTES.keys() as Array[String]

## Get palette description
func get_palette_info(palette_name: String) -> Dictionary:
	return ARTISTIC_PALETTES.get(palette_name, {})

## Node finding utilities
func get_indonesia_map_node() -> MeshInstance3D:
	var possible_paths = ["IndonesiaMap", "../IndonesiaMap", "../../IndonesiaMap"]
	
	for path in possible_paths:
		var node = get_node_or_null(path)
		if node and node is MeshInstance3D:
			return node as MeshInstance3D
	
	return _find_node_by_name(get_tree().current_scene, "IndonesiaMap") as MeshInstance3D

func get_sea_plane_node() -> MeshInstance3D:
	var possible_paths = ["SeaPlane", "../SeaPlane", "../../SeaPlane"]
	
	for path in possible_paths:
		var node = get_node_or_null(path)
		if node and node is MeshInstance3D:
			return node as MeshInstance3D
	
	return _find_node_by_name(get_tree().current_scene, "SeaPlane") as MeshInstance3D

func get_sun_light_node() -> DirectionalLight3D:
	return _find_node_by_name(get_tree().current_scene, "SunLight") as DirectionalLight3D

func _find_node_by_name(root: Node, target_name: String) -> Node:
	if root.name == target_name:
		return root
	
	for child in root.get_children():
		var result = _find_node_by_name(child, target_name)
		if result:
			return result
	
	return null

## Public API for runtime color adjustments
func increase_island_brightness(factor: float = 1.2):
	if "island" in enhanced_materials:
		var material = enhanced_materials["island"] as StandardMaterial3D
		var current_color = material.albedo_color
		material.albedo_color = current_color * factor
		GameLogger.info("🔆 Increased island brightness by: " + str(factor))

func adjust_emission_strength(strength: float):
	if "island" in enhanced_materials:
		var material = enhanced_materials["island"] as StandardMaterial3D
		material.emission_energy = strength
		GameLogger.info("✨ Adjusted emission strength to: " + str(strength))
